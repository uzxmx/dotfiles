class String
  def unicode_str(prefix: '0x', separator: ' ')
    self.chars.map { |c| format("#{prefix}%4.4x", c.ord) }.join(separator)
  end

  def bytes_str(prefix: '0x', separator: ' ')
    self.bytes.map { |b| format("#{prefix}%2.2x", b) }.join(separator)
  end
end
