def exec
  # オリジナルの例外（ZeroDivisionError）
  1 / 0
rescue => e
  # 例外処理中にtypo等で別の例外が起きる
  # （ZeroDivisionErrorはこの例外のcauseプロパティに格納される）
  e.messagee
end

exec