module CoreExt
  refine Hash do
    def thread_with
      mem = []
      map do |*item|
        Thread.new(*item) do |*_item|
          mem << yield(*_item)
        end
      end.each(&:join)
      mem
    end
  end
end
