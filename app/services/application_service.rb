class ApplicationService
  # Ensure subclasses have a .call class method and properly forward kwargs
  def self.inherited(subclass)
    super
    subclass.define_singleton_method(:call) do |*args, **kwargs, &block|
      subclass.new(*args, **kwargs, &block).call
    end
  end

  # Fallback for direct calls on ApplicationService itself
  def self.call(*args, **kwargs, &block)
    new(*args, **kwargs, &block).call
  end
end
