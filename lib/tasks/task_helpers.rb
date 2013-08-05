def colorize(text, color_code)
  "\e[#{color_code}m#{text}\e[0m"
end

{ # See: http://kpumuk.info/ruby-on-rails/colorizing-console-ruby-script-output/
  31 => 'red',
  32 => 'green',
  33 => 'yellow',
  34 => 'blue',
  35 => 'magenta',
  36 => 'cyan',
}.each do |code, color|
  Kernel.send(:define_method, color) { |text| colorize(text, code) }
end

def error(text);   puts red('ERROR: ') + text; end
def success(text); puts green('SUCCESS: ') + text; end
def warn(text);    puts yellow('WARNING: ') + text; end
