[L, R]  = [0, 1]
speed   = [1, 2]  # 左側、右側の速度
gap     = [2, 3]  # 左側、右側の詰め具合
waiting = [0, 0]  # 左側、右側の待ち行列の長さ

[BOTTOM, WAITING, ASCEND, TOP] = [0..3]

pair = location.search.substring(1).split('&')
for arg in pair
  kv = arg.split '='
  speed[L] = kv[1] if kv[0] == 'ls'
  gap[L] =   kv[1] if kv[0] == 'lg'
  speed[R] = kv[1] if kv[0] == 'rs'
  gap[R] =   kv[1] if kv[0] == 'rg'

[WINWIDTH, WINHEIGHT] = [500, 500]
lanepos = [220, 250]
escheight = 460

NPERSONS = 50
STAIRHEIGHT = 60

steppos = 0
done = false
stairspeed = 1.0
movespeed = 1.3

persons = []

class Person
  constructor : ->
    @x = 0.0
    @y = 0.0
    @status = BOTTOM
    @lr = L

setup = ->
  createCanvas WINWIDTH, WINHEIGHT
  frameRate 60
  for i in [0...NPERSONS]
    persons[i] = new Person()

boardable = (n, lr) -> # エスカレータに乗れる
  for i in [0...n]
    if persons[i].status == ASCEND and
       persons[i].lr == lr and
       persons[i].y - persons[n].y < STAIRHEIGHT * gap[lr]
      return false
  true
  
movable = (n, tb) -> # 歩ける
  for i in [0...NPERSONS]
    if persons[i].status == tb and
       persons[i].x - persons[n].x > 0.0 and
       persons[i].x - persons[n].x < 30.0
      return false
  true

finish = -> # 全員登りきった状況
  for i in [0...NPERSONS]
    return false if persons[i].status != TOP
  true

loops = 0

draw = ->
  return if done

  background 213, 200, 255

  y = steppos
  while true
    break if y > WINHEIGHT+STAIRHEIGHT
    fill 200,200,200
    strokeWeight 0
    rect lanepos[L]-10+10,WINHEIGHT-y,lanepos[R]-lanepos[L]+40,STAIRHEIGHT/2
    y += STAIRHEIGHT

  steppos += stairspeed
  steppos = 0 if steppos >= STAIRHEIGHT

  for i in [0...NPERSONS] # 駒をひとつずつ進める。
    switch persons[i].status
      when BOTTOM # 下で移動中
        if persons[i].x >= lanepos[L] and # 左レーンまでたどりついたとき
           persons[i].lr == L
          if waiting[L] < waiting[R]
            persons[i].status = WAITING
            persons[i].x = lanepos[L]
            waiting[L]++
          else
            persons[i].lr = R # 右で待つことにする
        else if persons[i].x >= lanepos[R] and # 右レーンまでたどりついたとき
                persons[i].lr == R
          persons[i].status = WAITING
          persons[i].x = lanepos[R]
          waiting[R]++
        if movable(i, BOTTOM) # 前に進める場合は一歩前に移動する
          persons[i].x += movespeed
      when TOP # エスカレータからおりている
        if movable(i, TOP) # 前に進める場合は一歩前に移動する
          persons[i].x += movespeed
      when WAITING # エスカレータ待ち状態
        lr = persons[i].lr
        if boardable(i,lr) # 上に余地がある
          persons[i].status = ASCEND
          waiting[lr]--
      when ASCEND # エスカレータに乗っていたら
        if persons[i].y >= escheight # エスカレータで上まで到達していればおりる
          persons[i].status = TOP
          persons[i].y = escheight
        else
          lr = persons[i].lr
          persons[i].y += stairspeed * speed[lr] # 1段上に移動する

  strokeWeight 1
  for i in [NPERSONS-1..0]
    fill(255,255,0)
    rect(persons[i].x+10,WINHEIGHT-30-persons[i].y,20,20)
    fill(0,0,0)
    text(i+1,persons[i].x+10+3,WINHEIGHT-30-persons[i].y+14)

  fill(0,0,0)
  text(loops,20,20)

  if finish()
    done = true
  else
    loops++
