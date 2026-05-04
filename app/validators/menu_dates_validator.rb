class MenuDatesValidator < ActiveModel::Validator
  def validate(record)
    starts_source = record.starts_on_input.presence || record.starts_on
    ends_source = record.ends_on_input.presence || record.ends_on

    record.starts_on = parse_date(starts_source)
    record.ends_on = parse_date(ends_source)

    validate_date_input(record, :starts_on_input, record.starts_on_input, starts_source, record.starts_on)
    validate_date_input(record, :ends_on_input, record.ends_on_input, ends_source, record.ends_on)

    return if record.errors[:starts_on_input].any? || record.errors[:ends_on_input].any?

    return if record.starts_on.blank? || record.ends_on.blank?

    record.errors.add(:ends_on_input, :after_start) if record.ends_on < record.starts_on
  end

  private

  def parse_date(value)
    return if value.blank?

    Date.iso8601(value.to_s.strip)
  rescue ArgumentError, TypeError
    nil
  end

  def validate_date_input(record, attribute, raw_input, source_value, parsed_value)
    if raw_input.blank? && source_value.blank?
      record.errors.add(attribute, :blank)
    elsif source_value.present? && parsed_value.nil?
      record.errors.add(attribute, :invalid)
    end
  end
end
