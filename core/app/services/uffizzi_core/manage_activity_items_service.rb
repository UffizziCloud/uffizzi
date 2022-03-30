# frozen_string_literal: true

class UffizziCore::ManageActivityItemsService
  attr_accessor :deployment, :containers, :pods, :namespace_data

  def initialize(deployment)
    @deployment = deployment
    @containers = deployment.active_containers
    @namespace_data = UffizziCore::ControllerService.fetch_namespace(deployment)
    @pods = UffizziCore::ControllerService.fetch_pods(deployment)
  end

  def container_status_item(container)
    container_status_items.detect { |container_statuses| container_statuses[:id] == container.id }
  end

  def container_status_items
    network_connectivities = build_network_connectivities
    containers_replicas = build_containers_replicas

    build_container_status_items(network_connectivities, containers_replicas)
  end

  private

  def build_network_connectivities
    containers.with_public_access.map do |container|
      { id: container.id, items: build_container_network_connectivity_items(container) }
    end
  end

  def build_container_network_connectivity_items(container)
    network_connectivities = container_network_connectivities(container)
    return [] if network_connectivities.nil?

    network_connectivities.map do |network_connectivity|
      type, value = network_connectivity

      { type: type, status: value.status }
    end
  end

  def build_containers_replicas
    containers.map do |container|
      repo = container.repo

      if repo.github?
        build = container.repo.builds.deployed.last

        if build.nil? || build.building?
          return [{ id: container.id,
                    items: [{ name: container.image_name, status: UffizziCore::Event.state.building }] }]
        end
        if !build.successful?
          return [{ id: container.id,
                    items: [{ name: container.image_name, status: UffizziCore::Event.state.failed }] }]
        end
      end

      items = pods.map do |pod|
        {
          name: item_name(pod, container),
          status: get_status(pod, container),
        }
      end

      { id: container.id, items: items }
    end
  end

  def build_container_status_items(network_connectivities, containers_replicas)
    containers.map do |container|
      network_connectivity = network_connectivities.detect { |item| item[:id] == container.id }
      any_container_is_building = containers_replicas.any? do |container_replicas|
        container_replicas[:items].any? do |item|
          item[:status] == UffizziCore::Event.state.building
        end
      end
      container_replicas = containers_replicas.detect { |item| item[:id] == container.id }

      {
        id: container.id,
        status: build_container_status(container, network_connectivity, container_replicas, any_container_is_building),
      }
    end
  end

  def replicas_contains_status?(replicas, status)
    replicas.any? { |replica| replica[:status] == status }
  end

  def build_container_status(container, network_connectivity, container_replicas, any_container_is_building)
    return building_container_status(container) if any_container_is_building

    error = replicas_contains_status?(container_replicas[:items], UffizziCore::Event.state.failed)
    container_is_running = replicas_contains_status?(container_replicas[:items], UffizziCore::Event.state.deployed)
    deployed = !error && container_is_running
    return container_status(error, deployed) unless container.public?

    network_connectivity[:items].each do |item|
      status = item[:status].to_sym
      error ||= status == :failed
      deployed &&= status == :success
    end

    container_status(error, deployed)
  end

  def building_container_status(container)
    return UffizziCore::Event.state.building if container.repo.github?

    UffizziCore::Event.state.deploying
  end

  def container_status(error, deployed)
    return UffizziCore::Event.state.failed if error
    return UffizziCore::Event.state.deployed if deployed

    UffizziCore::Event.state.deploying
  end

  def item_name(pod, container)
    hash = pod.metadata.name.split('-').last
    "#{container.image_name}-#{hash}"
  end

  def get_status(pod, container)
    pod_container = pod_container(pod, container)

    return UffizziCore::Event.state.deploying if pod_container.nil? || pod_container[:state].to_h.empty?

    pod_container_status = pod_container[:state].keys.first
    state = pod_container[:state][pod_container_status]
    reason = state&.reason

    case pod_container_status.to_sym
    when :running
      UffizziCore::Event.state.deployed
    when :terminated
      UffizziCore::Event.state.failed
    when :waiting
      return Event.state.failed if ['ErrImagePull', 'ImagePullBackOff', 'CrashLoopBackOff'].include?(reason)

      UffizziCore::Event.state.deploying
    else
      UffizziCore::Event.state.deploying
    end
  end

  def pod_container(pod, container)
    pod_name = UffizziCore::ContainerService.pod_name(container)

    pod&.status&.container_statuses&.detect { |cs| cs.name.include?(pod_name) }
  end

  def container_network_connectivities(container)
    network_connectivity = Hashie::Mash.new(JSON.parse(deployment_network_connectivity))
    containers_network_connectivity = network_connectivity&.containers

    containers_network_connectivity[container.id.to_s] if !containers_network_connectivity.nil?
  end

  def deployment_network_connectivity
    namespace_data&.metadata&.annotations&.network_connectivity || '{}'
  end
end
