require 'faker'

class ValidString

  def initialize model_object:, key:
    @model_object = model_object
    @key = key
  end

  def generate
    validator_names = validators.map{|m| m.class.name.demodulize}

    case validator_names

    # Regex だけを考える
    when include_format?
      return formatted_str

    # Integer を返す
    when include_numericality?
      first_str = rand(1..9).to_s
      rest_str = (1...num_of_chars).map{rand(0..9)}.join
      return data = first_str + rest_str

    # String を返す
    else
      data = (1..num_of_chars).map{('a'..'z').to_a[rand(26)]}.join
      return data
    end
  end


  private

  def formatted_str
    # NOTE: 複数の FormatValidator が存在しうるが、それを考慮するのは、
    # 大変すぎる気がするので、一番最後のものだけを反映させてます。ひとまず..
    regex = format_validators.map{|m| m.options[:with]}.last
    Faker::Base.regexify(regex)
  end

  def validators
    @model_object._validators[@key.to_sym]
  end

  def length_validators
    validators.select{ |m|
      m.class.name.demodulize == "LengthValidator"
    }
  end

  def format_validators
    validators.select{ |m|
      m.class.name.demodulize == "FormatValidator"
    }
  end

  # @return [Integer] 文字数
  def num_of_chars
    # ex) {:minimum=>5, :maximum=>9}
    merged_options = length_validators.map(&:options).inject({}, :merge)

    minimum = merged_options[:minimum] || 0
    maximum = merged_options[:maximum] || 16
    rand(minimum..maximum)
  end


  def include_format?
    ->(arr){ arr.include? "FormatValidator" }
  end

  def include_numericality?
    ->(arr){ arr.include? "NumericalityValidator" }
  end

  def include_length?
    ->(arr){ arr.include? "LengthValidator" }
  end
end
