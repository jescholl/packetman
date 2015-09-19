module ConstantsHelper

  def overwrite_constant(constant, value, object = Object)
    constant = constant.to_sym
    saved_constants[object] ||= {}
    saved_constants[object][constant] = object.const_get(constant) unless saved_constants[object].has_key?(constant)
    silence_warnings { object.const_set(constant, value) }
  end

  def overwrite_constants(constants = {}, object = Object)
    constants.each do |constant, value|
      overwrite_constant(constant, value, object)
    end
  end

  def reset_constant(constant, object = Object)
    return nil unless saved_constants[object]
    constant = constant.to_sym
    silence_warnings { object.const_set(constant, saved_constants[object][constant]) }
    saved_constants[object].delete(constant)
  end

  def reset_constants(constants = nil, object = Object)
    return nil unless saved_constants[object]
    constants ||= saved_constants[object].keys
    constants.each do |constant|
      reset_constant(constant, object)
    end
  end

  def reset_all_constants
    saved_constants.keys.each do |object|
      reset_constants(nil, object)
    end
  end

  def saved_constants
    @saved_constants ||= {}
  end

  def silence_warnings
    old_verbose, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = old_verbose
  end

end
