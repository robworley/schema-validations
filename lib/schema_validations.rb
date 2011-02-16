module SchemaValidations
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def self.extended(base)
      base.send(:class_inheritable_array, :schema_validations_to_skip)
      base.send(:schema_validations_to_skip=, [])

      class << base
        alias_method_chain :allocate, :schema_validations
        alias_method_chain :new, :schema_validations
      end
    end

    def skip_schema_validations(*syms)
      self.schema_validations_to_skip = syms
    end

    def allocate_with_schema_validations
      load_schema_validations
      allocate_without_schema_validations
    end

    def new_with_schema_validations(*args)
      load_schema_validations
      new_without_schema_validations(*args) { |*block_args| yield(*block_args) if block_given? }
    end

    protected

    def load_schema_validations
      # Don't bother if: it's already been loaded; the table doesn't exist; the class is abstract
      return if @schema_validations_loaded || !table_exists? || abstract_class?
      @schema_validations_loaded = true
      load_column_validations
      load_association_validations
    end

    private

    def load_column_validations
      content_columns.each do |column|
        next unless validates?(column)

        name = column.name.to_sym

        # Data-type validation
        if column.type == :integer
          validates_numericality_of name, :allow_nil => true, :only_integer => true
        elsif column.number?
          validates_numericality_of name, :allow_nil => true
        elsif column.text? && column.limit
          validates_length_of name, :allow_nil => true, :maximum => column.limit
        end

        # NOT NULL constraints
        unless column.null
          # Work-around for a "feature" of the way validates_presence_of handles boolean fields
          # See http://dev.rubyonrails.org/ticket/5090 and http://dev.rubyonrails.org/ticket/3334
          if column.type == :boolean
            validates_inclusion_of name, :in => [true, false], :message => I18n.translate('activerecord.errors.messages.blank')
          else
            validates_presence_of name
          end
        end
      end
    end

    def load_association_validations
      columns = columns_hash
      reflect_on_all_associations(:belongs_to).each do |association|
        column = columns[association.primary_key_name]
        next unless validates?(column)

        # NOT NULL constraints
        module_eval(
          "validates_presence_of :#{column.name}, :if => lambda { |record| record.#{association.name}.nil? }"
        ) unless column.null
      end
    end

    def validates?(column)
      column && column.name !~ /^(((created|updated)_(at|on))|position)$/ &&
        !self.schema_validations_to_skip.include?(column.name.to_sym)
    end
  end
end
