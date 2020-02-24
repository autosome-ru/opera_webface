import time
while True:
  try:
    print('smth')
    time.sleep(1)
  except Exception:
    print('caught')
