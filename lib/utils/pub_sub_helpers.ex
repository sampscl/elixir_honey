defmodule Utils.PubSubHelpers do
  @moduledoc """
  Helper macros for PubSub
  """
  defmacro __using__(_opts) do
    quote do
      import Flub, only: [p: 1]
      import Utils.PubSubHelpers
    end
  end

  @doc """
  Define a `Flub` channel and associated helper functions. Used like so:

    defmodule PubSub do
      import PubSub.Helpers
      use PubSub.Helpers

      define_channel("alert_notice", level: :info, description: "default description")
    end

  the `define_channel` macro will introduce the following code for you:

    defmodule AlertNotice do
      defstruct [
        level: :info,
        description: "default description",
      ]
    end

    def alert_notice_chnl(), do: :alert_notice
    def pub_alert_notice(val), do: Flub.pub(val, alert_notice_chnl())
    def sub_alert_notice(), do: Flub.sub(alert_notice_chnl())
    def sub_alert_notice(opts), do: Flub.sub(alert_notice_chnl(), opts)

  """
  defmacro define_channel(channel_string, channel_def_kwl) do

    camel_channel_string = Macro.camelize(channel_string)
    snake_channel_string = Macro.underscore(channel_string)
    channel_atom = String.to_atom(snake_channel_string)
    struct_mod = String.to_atom("Elixir.PubSub.#{camel_channel_string}")
    get_chnl = String.to_atom("#{channel_string}_chnl")
    pub_chnl = String.to_atom("pub_#{channel_string}")
    sub_chnl = String.to_atom("sub_#{channel_string}")

    struct = quote do
      defmodule unquote(struct_mod) do
        defstruct unquote(channel_def_kwl)
      end
    end

    funcs = quote do

      def unquote(get_chnl)() do
        unquote(channel_atom)
      end

      def unquote(pub_chnl)(arg) do
        Flub.pub(arg, unquote(get_chnl)())
      end

      def unquote(sub_chnl)(opts) do
        Flub.sub(unquote(get_chnl)(), opts)
      end

      def unquote(sub_chnl)() do
        Flub.sub(unquote(get_chnl)())
      end

    end

    [struct, funcs]
  end
end
