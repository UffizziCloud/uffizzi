# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_04_20_103952) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "uffizzi_core_accounts", force: :cascade do |t|
    t.text "name"
    t.text "kind", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "customer_token"
    t.string "state"
    t.string "subscription_token"
    t.datetime "payment_issue_at"
    t.string "domain"
    t.boolean "sso_enabled", default: false
    t.bigint "owner_id"
    t.integer "container_memory_limit"
    t.string "workos_organization_id"
    t.string "sso_state"
    t.index ["customer_token"], name: "index_accounts_on_customer_token", unique: true
    t.index ["domain"], name: "index_accounts_on_domain", unique: true
    t.index ["subscription_token"], name: "index_accounts_on_subscription_token", unique: true
  end

  create_table "uffizzi_core_activity_items", force: :cascade do |t|
    t.bigint "deployment_id", null: false
    t.string "namespace"
    t.string "name"
    t.string "tag"
    t.string "branch"
    t.string "type"
    t.bigint "container_id", null: false
    t.string "commit"
    t.string "commit_message"
    t.bigint "build_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "data", default: {}, null: false
    t.string "digest"
    t.index ["container_id"], name: "index_activity_items_on_container_id"
    t.index ["deployment_id"], name: "index_activity_items_on_deployment_id"
  end

  create_table "uffizzi_core_builds", force: :cascade do |t|
    t.bigint "repo_id", null: false
    t.string "build_id"
    t.string "repository"
    t.string "branch"
    t.string "commit"
    t.string "committer"
    t.string "message"
    t.string "log_url"
    t.integer "status"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "deployed"
    t.index ["build_id"], name: "index_builds_on_build_id", unique: true
    t.index ["repo_id"], name: "index_builds_on_repo_id"
  end

  create_table "uffizzi_core_comments", force: :cascade do |t|
    t.string "commentable_type"
    t.bigint "commentable_id"
    t.text "content"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "ancestry"
    t.integer "ancestry_depth", default: 0
    t.index ["ancestry"], name: "index_comments_on_ancestry"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "uffizzi_core_compose_files", force: :cascade do |t|
    t.string "source"
    t.bigint "repository_id"
    t.string "branch"
    t.string "path"
    t.string "auto_deploy"
    t.bigint "added_by_id"
    t.bigint "project_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "state"
    t.jsonb "payload", default: {}, null: false
    t.text "content"
    t.string "kind", default: "main"
    t.index ["project_id"], name: "index_compose_files_on_project_id"
  end

  create_table "uffizzi_core_config_files", force: :cascade do |t|
    t.string "filename"
    t.string "kind"
    t.bigint "added_by_id"
    t.text "payload"
    t.bigint "project_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "compose_file_id"
    t.string "creation_source"
    t.string "source"
    t.index ["compose_file_id"], name: "index_config_files_on_compose_file_id"
    t.index ["project_id"], name: "index_config_files_on_project_id"
  end

  create_table "uffizzi_core_container_config_files", force: :cascade do |t|
    t.string "mount_path"
    t.bigint "container_id", null: false
    t.bigint "config_file_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["config_file_id"], name: "index_container_config_files_on_config_file_id"
    t.index ["container_id"], name: "index_container_config_files_on_container_id"
  end

  create_table "uffizzi_core_containers", force: :cascade do |t|
    t.string "image"
    t.string "tag"
    t.jsonb "variables"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "deployment_id"
    t.boolean "public", default: false, null: false
    t.integer "port"
    t.bigint "repo_id"
    t.string "state"
    t.string "continuously_deploy", null: false
    t.string "kind", default: "user"
    t.integer "target_port"
    t.string "controller_name"
    t.boolean "receive_incoming_requests"
    t.integer "memory_request"
    t.integer "memory_limit"
    t.jsonb "secret_variables"
    t.string "entrypoint"
    t.string "command"
    t.string "name"
    t.jsonb "healthcheck"
    t.index ["deployment_id"], name: "index_containers_on_deployment_id"
    t.index ["repo_id"], name: "index_containers_on_repo_id"
  end

  create_table "uffizzi_core_coupons", force: :cascade do |t|
    t.string "token"
    t.string "name", null: false
    t.string "currency", null: false
    t.bigint "amount_off", null: false
    t.string "duration", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "uffizzi_core_credentials", force: :cascade do |t|
    t.string "type"
    t.string "username"
    t.string "password"
    t.bigint "project_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "provider_ref"
    t.bigint "account_id"
    t.string "state"
    t.string "registry_url"
    t.index ["account_id"], name: "index_credentials_on_account_id"
    t.index ["project_id"], name: "index_credentials_on_project_id"
    t.index ["provider_ref"], name: "index_credentials_on_provider_ref"
  end

  create_table "uffizzi_core_deployments", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.text "kind", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "creator_name"
    t.string "subdomain"
    t.string "state"
    t.float "memory_limit"
    t.bigint "deployed_by_id"
    t.bigint "continuous_preview_id_deprecated"
    t.jsonb "continuous_preview_payload"
    t.string "creation_source"
    t.bigint "compose_file_id"
    t.bigint "template_id"
    t.index ["compose_file_id"], name: "index_deployments_on_compose_file_id"
    t.index ["project_id"], name: "index_deployments_on_project_id"
    t.index ["template_id"], name: "index_deployments_on_template_id"
  end

  create_table "uffizzi_core_events", force: :cascade do |t|
    t.bigint "activity_item_id", null: false
    t.string "state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["activity_item_id"], name: "index_events_on_activity_item_id"
  end

  create_table "uffizzi_core_invitations", force: :cascade do |t|
    t.text "email", null: false
    t.text "token", null: false
    t.string "status", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "invited_by_id", null: false
    t.bigint "entityable_id", null: false
    t.string "entityable_type", null: false
    t.string "role", null: false
    t.bigint "invitee_id"
    t.index ["token"], name: "index_invitations_on_token", unique: true
  end

  create_table "uffizzi_core_memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "account_id", null: false
    t.text "role", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_memberships_on_account_id"
    t.index ["user_id", "account_id"], name: "index_memberships_on_user_id_and_account_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "uffizzi_core_payments", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "charge_id"
    t.string "status"
    t.float "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_payments_on_account_id"
  end

  create_table "uffizzi_core_prices", force: :cascade do |t|
    t.string "token"
    t.string "slug", null: false
    t.string "name", null: false
    t.float "units_price", null: false
    t.bigint "units_amount", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["product_id"], name: "index_prices_on_product_id"
  end

  create_table "uffizzi_core_products", force: :cascade do |t|
    t.string "token"
    t.string "slug", null: false
    t.string "name", null: false
    t.string "type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "kind"
  end

  create_table "uffizzi_core_projects", force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "account_id", null: false
    t.string "state"
    t.string "slug"
    t.string "description"
    t.index ["account_id", "name"], name: "index_projects_on_account_id_and_name", unique: true
    t.index ["account_id"], name: "index_projects_on_account_id"
  end

  create_table "uffizzi_core_ratings", force: :cascade do |t|
    t.string "name"
    t.string "state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "uffizzi_core_repos", force: :cascade do |t|
    t.string "namespace"
    t.string "name"
    t.string "tag"
    t.string "type"
    t.string "branch"
    t.bigint "project_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "description"
    t.boolean "is_private"
    t.string "slug"
    t.bigint "repository_id"
    t.string "kind"
    t.string "dockerfile_path"
    t.jsonb "args"
    t.string "dockerfile_context_path"
    t.boolean "deploy_preview_when_pull_request_is_opened"
    t.boolean "delete_preview_when_pull_request_is_closed"
    t.boolean "deploy_preview_when_image_tag_is_created"
    t.boolean "delete_preview_when_image_tag_is_updated"
    t.boolean "share_to_github"
    t.integer "delete_preview_after"
    t.string "tag_pattern_deprecated"
    t.index ["project_id"], name: "index_repos_on_project_id"
  end

  create_table "uffizzi_core_roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "uffizzi_core_secrets", force: :cascade do |t|
    t.string "name"
    t.string "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "resource_type"
    t.bigint "resource_id"
    t.index ["resource_type", "resource_id"], name: "index_uffizzi_core_secrets_on_resource"
  end

  create_table "uffizzi_core_templates", force: :cascade do |t|
    t.string "name"
    t.bigint "added_by_id"
    t.jsonb "payload", null: false
    t.bigint "project_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "compose_file_id"
    t.string "creation_source"
    t.index ["project_id"], name: "index_templates_on_project_id"
  end

  create_table "uffizzi_core_user_projects", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "project_id", null: false
    t.text "role", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "invited_by_id"
    t.index ["project_id"], name: "index_user_projects_on_project_id"
    t.index ["user_id", "project_id"], name: "index_user_projects_on_user_id_and_project_id"
    t.index ["user_id"], name: "index_user_projects_on_user_id"
  end

  create_table "uffizzi_core_users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email", default: "", null: false
    t.string "password_digest", default: "", null: false
    t.string "confirmation_token"
    t.string "state"
    t.string "phone"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "github"
    t.string "website"
    t.string "twitter"
    t.string "linkedin"
    t.string "devto"
    t.string "facebook"
    t.string "blog"
    t.text "bio"
    t.string "status"
    t.string "availability"
    t.string "primary_skills"
    t.string "learning"
    t.string "coding_for"
    t.string "education"
    t.string "title"
    t.string "work"
    t.string "primary_location"
    t.string "creation_source"
    t.index "lower((email)::text)", name: "index_email_on_lower_email", unique: true
  end

  create_table "uffizzi_core_users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

end
