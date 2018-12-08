def exec
  1 / 0
rescue => e
  puts "default ====="
  puts e.full_message
  puts
  puts "highlight: false ====="
  puts e.full_message(highlight: false)
  puts
  puts "order: top ====="
  puts e.full_message(order: :top)
  puts
end

exec
