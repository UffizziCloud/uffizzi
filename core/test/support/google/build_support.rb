# frozen_string_literal: true

class Google::Cloud::BuildMock
  def create_build(*_args)
    build_object
  end

  def get_build(*_args)
    build_object
  end

  private

  def build_object
    OpenStruct.new({
                     grpc_op: {
                       metadata: {
                         build: {
                           id: 1,
                         },
                       },
                     },
                     start_time: DateTime.now,
                     finish_time: DateTime.now,
                     status: :SUCCESS,
                   })
  end
end
