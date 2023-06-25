ENV['TZ'] = 'CET'

class SungrowRecord
  def initialize(row)
    @row = row
  end

  attr_reader :row

  def to_h
    { name: 'SENEC', time:, fields: }
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
      bat_charge_current:,
      bat_voltage:,
      grid_power_plus:,
      grid_power_minus:,
      # There is no data for the wallbox, but we can estimate it
      wallbox_charge_power: estimated_wallbox_charge_power,
    }
  end

  def inverter_power
    @inverter_power ||=
      parse_kw(row, ['PV-Ertrag(W)'])
  end

  def house_power
    @house_power ||=
      parse_kw(row, 'Gesamtverbrauch(W)'   )
  end

  def bat_power_plus
    @bat_power_plus ||=
      parse_kw(
        row,
        'Batterie(W)'
      )
  end

  def bat_power_minus
    # The CSV file format has changed over time, so two different column names are possible
    @bat_power_minus ||=
      parse_kw(
        row,
        'Batterie(W)'
      )
  end

  def bat_charge_current
    @bat_charge_current ||= parse_a(row, 'Akku Stromstärke [A]')
  end

  def bat_voltage
    @bat_voltage ||= parse_v(row, 'Akku Spannung [V]')
  end

  def grid_power_plus
    @grid_power_plus ||= parse_kw(row, 'Netz(W)')
  end

  def grid_power_minus
    @grid_power_minus ||=
      parse_kw_negative(row, 'Netz(W)')
  end

  def estimated_wallbox_charge_power
    incoming = inverter_power + grid_power_plus + bat_power_minus
    outgoing = grid_power_minus + house_power + bat_power_plus
    diff = incoming - outgoing

    diff < 50 ? 0 : diff
  end

  # KiloWatt
  def parse_kw(row, *columns)
    cell = cell(row, *columns)
    (cell.sub(',', '.').to_f / 1_000).round
  end

  # KiloWatt
  def parse_kw_negative(row, *columns)
    cell = cell(row, *columns)
    (cell.sub(',', '.').to_f / 1_000).round
  end

  # Ampere
  def parse_a(row, *columns)
    '0'.to_f
  end

  # Volt
  def parse_v(row, *columns)
    '0'.to_f
  end

  # Time
  def parse_time(row, string)
    zeit = row[string]
    Time.parse("#{zeit} CET").to_i
  end

  def cell(row, *columns)
    # Find column by name (can have different names due to CSV format changes)
    column = columns.find { |col| row[col] }

    row[column] || throw("Column #{columns.join(' or ')} not found")
  end
end
