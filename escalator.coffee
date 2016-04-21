speed = [1, 2]
gap =   [2, 3]
[L, R] = [0, 1]
waiting = [0, 0]
[BOTTOM, WAITING, ASCEND, TOP] = [0..3]

pair = location.search.substring(1).split('&')
for arg in pair
  kv = arg.split('=')
  speed[L] = kv[1] if kv[0] == 'ls'
  gap[L] =   kv[1] if kv[0] == 'lg'
  speed[R] = kv[1] if kv[0] == 'rs'
  gap[R] =   kv[1] if kv[0] == 'rg'

lanepos = [220, 250]
escheight = 460

[WINWIDTH, WINHEIGHT] = [500, 500]

NPERSONS = 50
STAIRS = 15
STAIRHEIGHT = 60
STEPUNIT = 1
steppos = 0
done = false
movespeed = 1.3

persons = []

loops = 0

class Person
  constructor : ->
    @x = 0.0
    @y = 0.0
    @status = BOTTOM
    @lr = L

setup = ->
  createCanvas WINWIDTH, WINHEIGHT
  frameRate 60
  # [0...NPERSONS].forEach (i) ->
  for i in [0...NPERSONS]
    persons[i] = new Person()

can_ascend = (n, lr) ->
  for i in [0...n]
    if persons[i].status == ASCEND and
       persons[i].lr == lr and
       persons[i].y - persons[n].y < STAIRHEIGHT * gap[lr]
      return false
  return true
  
can_move_bottom = (n) ->
  for i in [0...n]
    if persons[i].status == BOTTOM and
       persons[i].x - persons[n].y < 30.0
      return false
  return true

can_move_top = (n) ->
  for i in [0...NPERSONS]
    if persons[i].status == TOP and
       persons[i].x - persons[n].x > 0.0 and
       persons[i].x - persons[n].x < 30.0
      return false
  return true

all_top = ->
  for i in [0...NPERSONS]
    return false if persons[i].status != TOP
  return true

draw = ->
  return if done

  background 213, 200, 255

  for i in [0...STAIRS]
    y = i * STAIRHEIGHT + steppos
    fill 200,200,200
    strokeWeight 0
    rect lanepos[L]-10+10,WINHEIGHT-y,lanepos[R]-lanepos[L]+40,STAIRHEIGHT/2

  steppos += STEPUNIT
  steppos = 0 if steppos >= STAIRHEIGHT

  if all_top()
    done = true
  else
    loops++

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
        if can_move_bottom(i) # 前に進める場合は一歩前に移動する
          persons[i].x += movespeed
      when TOP # エスカレータからおりている
        if can_move_top(i) # 前に進める場合は一歩前に移動する
          persons[i].x += movespeed
      when WAITING # エスカレータ待ち状態
        lr = persons[i].lr
        if can_ascend(i,lr) # 上に余地がある
          persons[i].status = ASCEND
          waiting[lr]--
          
        #if persons[i].lr == L and # 左で待っていて
        #   can_ascend(i,L) # 上に余地がある
        #  persons[i].status = ASCEND
        #  waiting[L]--
        #else if persons[i].lr == R and # 右で待っていて
        #        can_ascend(i,R) # 上に余地がある
        #  persons[i].status = ASCEND
        #  waiting[R]--
      when ASCEND # エスカレータに乗っていたら
        if persons[i].y >= escheight # エスカレータで上まで到達していればおりる
          persons[i].status = TOP
          persons[i].y = escheight
        else
          if persons[i].lr == L
            persons[i].y += STEPUNIT * speed[L] # 1段上に移動する
          else
            persons[i].y += STEPUNIT * speed[R] # 1段上に移動する

  strokeWeight 1
  for i in [0..NPERSONS-1]
    j = NPERSONS-1-i
    fill(255,255,0)
    rect(persons[j].x+10,WINHEIGHT-30-persons[j].y,20,20)
    fill(0,0,0)
    text(j+1,persons[j].x+10+3,WINHEIGHT-30-persons[j].y+14)

  fill(0,0,0)
  text(loops,20,20)
