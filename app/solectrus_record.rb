ENV['TZ'] = 'CET'

class SolectrusRecord
  def initialize(row, measurement:)
    @row = row
    @measurement = measurement
  end

  attr_reader :row, :measurement

  def to_h
    { name: measurement, time:, fields: }
  end

  private

  def time
    parse_time(row, 'Zeit')
  end

  def fields
    {
      inverter_power:,
      house_power:,
      bat_power_plus:,
      bat_power_minus:,
      bat_fuel_charge: nil,
      grid_power_plus:,
      grid_power_minus:,
    }
  end

  def inverter_power
    @inverter_power ||= parse_kw(row, 'PV-Ertrag(W)')
  end

  def house_power
    @house_power ||= parse_kw(row, 'Gesamtverbrauch(W)')
  end

  def bat_power_plus
    @bat_power_plus ||= bat_power.negative? ? -bat_power : 0.0
  end

  def bat_power_minus
    @bat_power_minus ||= bat_power.positive? ? bat_power : 0.0
  end

  def bat_power
    @bat_power ||= parse_kw(row, 'Batterie(W)')
  end

  def grid_power_plus
    @grid_power_plus ||= grid_power.positive? ? grid_power : 0.0
  end

  def grid_power_minus
    @grid_power_minus ||= grid_power.negative? ? -grid_power : 0.0
  end

  def grid_power
    @grid_power ||= parse_kw(row, 'Netz(W)')
  end

  # KiloWatt
  def parse_kw(row, *columns)
    cell(row, *columns).to_f
  end

  # Time
  def parse_time(row, string)
    Time.parse("#{row[string]} CET").to_i
  end

  def cell(row, *columns)
    # Find column by name (can have different names due to CSV format changes)
    column = columns.find { |col| row[col] }

    row[column] || throw("Column #{columns.join(' or ')} not found")
  end
end
