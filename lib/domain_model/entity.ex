defmodule DomainModel.Entity do
  defmacro __using__(fields: fields) do
    quote do
      import Kernel, except: [apply: 2]

      defstruct id: nil, state: nil, events: [], version: 0

      defmodule State do
        defstruct unquote(fields)
      end

      def new(id) do
        %__MODULE__{id: id, state: %__MODULE__.State{}}
      end

      def load(id, events) do
        entity = %__MODULE__{id: id, state: %__MODULE__.State{}}
        Enum.reduce(events, entity, &apply(&2, &1))
      end

      defp apply_event(%__MODULE__{} = entity, event, update_state_fn) do
        %__MODULE__{entity |
          events: [event | entity.events],
          state: update_state_fn.(entity.state),
          version: entity.version + 1
        }
      end
    end
  end
end