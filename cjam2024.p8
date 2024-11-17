pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--cabin jam 2024 to-do

--a slim short jrpg
--grow stronger with each death
--dif dialogue/endings based on
-- number of deaths
--megaman battle network inspired
-- combat system. turn based.
-- push/pull into the breach-esque
-- mechanics

-- to do

--explore state
---[x]map
---[x]walls
---[x]dialogue
---[x]npcs
---[x]transitions
--combat state
---[x]player grid, enemy grid
---turns
---[x]select card
---[x]select target
---cards, random draw
---card effects, dmg, heal

---multiple characters
---=multiple moves	

--card select
--z zelect, x examine
---examine mode

--design cards
--equipment

-->8
--life cycle functions

function _init()
	timer=1
	app_state = mk_title_st()
end

function _update()
 timer+=1
	app_state:update()
end

function _draw()
	cls()
	app_state:draw()
end
-->8
--title state

function mk_title_st() 
	local st = {} --state
	
	st.title={
		txt={
			"cabin jam 2024 project",
			"bingo",
			"jammo"
		},		
		draw=function(self)
		 local txt=self.txt
			local tp
			tp=cent_txt_tbl_pos(txt)
			for i,l in ipairs(tp) do
				print(txt[i],l[1],l[2])
			end
		end
	}
	
	st.ins={--instructions
		w=96,
		h=20,
		y=88,
		txt="press ❎ to start",
		get_x=function(s)
			return cent_box(s.w,s.h)[1]
		end,
		get_t_pos=function(s)
			return cent_txt_pos(s.txt,{
				x=s:get_x(),
				y=s.y,
				w=s.w,
				h=s.h
			})
		end,
		draw=function(s)
			local ex=s:get_x()+s.w
			local ey=s.y+s.h
			local t_pos=s:get_t_pos()
			rect(s:get_x(),s.y,ex,ey)
			print(s.txt,t_pos[1],t_pos[2])
		end
	}
	
	function	st:update()
		if(btnp(❎))then
			app_state=mk_active_g_st()
		end
	end
	
	function st:draw()
		self.title:draw()
		self.ins:draw()
	end

	return st
end
-->8
--active game state

function mk_active_g_st()
	local st = {}
	st.screen_st=mk_combat_st()
	st.party={
		{
			mk_hero()
		}
	}
	
	function st:update()
		st.screen_st:update()
	end
	
	function st:draw()
		st.screen_st:draw()	
	end
	
	return st
end
-->8
--explore state

function mk_explore_st()
	local st={}
	st.rooms=mk_rooms()
	st.cur_r=1 --current room
	st.p=mk_player(30,30)
	
	function st:get_cur_room()
		return self.rooms[self.cur_r]
	end
	
	function st:update()
		self:handle_inputs()
		local room
		room = self:get_cur_room()
		room:update()
		self.p:update(room)
		self:handle_doors()
	end
	
	function st:draw()
		local room
		room = self:get_cur_room()
		room:draw()
		self.p:draw(room)
		if(self.diag)then
			self.diag:draw()
		end
		room = self:get_cur_room()
	end
	
	function st:handle_doors()
		local room
		local p = self.p
		local ec = p:engage_col()
		room = self:get_cur_room()
		for door in all(room.doors)do
			if(colliding(door.col,ec))then
				print('bbbbb')
				self.cur_r=door.dest.room_id
				local p_start
				p_start=door.dest.p_start(p)
				self.p.x=p_start[1]
				self.p.y=p_start[2]
			end
		end
	end
	
	function st:handle_inputs()
		self.controller:update(self)
	end

	function st.mk_explore_cont()
		local cont={
			st='walk',
			st_conts={}
		}
		function cont:set(st)
			if(self.st!=st)then
				self.st=st
			end
		end
		
		function cont:update(a_st)
			local cont 
			cont=self.st_conts[self.st]
			cont(self,a_st)
		end

		function	cont.st_conts:walk(a_st)
			local p = a_st.p
			local r=a_st.rooms[a_st.cur_r]
			local moving = false
			if(btn(⬆️))then
				p:move(⬆️)
				moving=true
			end
			if(btn(➡️))then
				p:move(➡️)
				moving=true	
			end
			if(btn(⬇️))then
				p:move(⬇️)
				moving=true
			end
			if(btn(⬅️))then
				p:move(⬅️)
				moving=true
			end
			if(btnp(🅾️))then
				local ec=p:engage_col()
				for npc in all(r.npcs) do
					if(colliding(npc:col(),ec))then
						self:set("diag")
						a_st.diag=mk_diag(p,npc.txt)
					end
				end
			end
			
			if(moving)then
				p.st='walk'
			else
				p.st='idle'
			end
		end
		
		function	cont.st_conts:diag(a_st)
			local d = a_st.diag
			if(btnp(🅾️)) d.cur+=1
			if(d.cur>#d.txt)then
				cont:set('walk')
				a_st.diag=nil
			end
		end		
		return cont
	end
	
	st.controller=st:mk_explore_cont()

	return st
end

function mk_rooms(p)
	local rooms = {}
	rooms[1]=mk_room({
		map_id=0,
		doors={
		 {
				col={
					134,
					48,
					136,
					64
				},
				dest={
					room_id=2,
					p_start=function(p)
						return {0,p.y}
					end
				}
			}
		},
		npcs={
			mk_cloak_npc({
				x=8,
				y=16,
				txt={
				 {
						'hiya! ♥',
						'boom! ★'
					},
					{
						'i only tell the truth'
					}
				}
			}),
			mk_cloak_npc({
				x=8,
				y=76,
				txt={
				 {
						'hiya! ♥',
						'bang! ◆'
					},
					{
						'i only tell lies'
					}
				}
			})
		}
	})
	
	rooms[2]=mk_room({
		map_id=1,
		doors={
			{
				col={
					-6,
					48,
					-8,
					64
				},
				dest={
					room_id=1,
					p_start=function(p)
						return {124,p.y}
					end
				}
			}
		},
		npcs={
			mk_cloak_npc({
			 x=80,
			 y=24,
			 txt={
			 	{
			 		"can you feel the rot",
			 		"in your eyes?"
			 	}
			 },
			 left=true
			})
		}
	})
		
	return rooms
end

function map_walls(map_id)
	local walls={}
	local off = map_id*16
	for y=0,16 do
		for x=0,16 do
			local mt=mget(x+off,y)
			if(fget(mt,0))then
				sx=x*8
				sy=y*8
				local wall={sx,sy,sx+7,sy+7}
				add(walls,wall)
			end
		end
	end
	
	return walls
end

function mk_room(opt)
	local r = {}
	local map_id=opt.map_id
	local npcs=opt.npcs or {}
	r.map_id=map_id
	r.npcs=npcs
	r.walls={}
	r.npc_cols={}
	r.doors=opt.doors or {}
	
	local m_walls=map_walls(map_id)
	copy_tbl_into(m_walls,r.walls)
	
	local npc_cols={}
	for npc in all(npcs) do
		add(npc_cols,npc:col())
	end
	
	r.npc_cols=npc_cols
	copy_tbl_into(npc_cols,r.walls)

	function r:update()
		for npc in all(r.npcs) do
			npc:update()
		end
	end
	
	function r:draw()
		local x = self.map_id*16
		map(x,0)
		for npc in all(r.npcs) do
			npc:draw()
		end
	end
	
	return r
end

function get_map_flags(map_id)
	local offset=map_id*16
	for y=0,16 do
		for x=0,16 do
		 local m_tile
		 m_tile=mget(x+offset,y+offset)
			
		end
	end
end
-->8
--explore entities

function mk_player(x,y)
	local speed=1
	local p = {
		st='idle',
		x=x,
		y=y,
		right=false,
		anim=mk_animator({
			anim_tbl={
				idle={
					{
						spr=4,
						time=10
					},
					{
					 spr=7,
					 time=15
					}
				},
				walk={
					{
						spr=4,
						time=5
					},
					{
					 spr=5,
					 time=2,
					},
					{
					 spr=4,
					 time=5
					},
					{
					 spr=6,
					 time=2
					}
				}
			}
		})
	}
	
	function p:move(dir)
		if(dir==⬆️)then
			p.y-=speed
		end
		if(dir==➡️)then
			p.x+=speed
			p.right=true
		end
		if(dir==⬇️)then
			p.y+=speed
		end
		if(dir==⬅️)then
			p.x-=speed
			p.right=false
		end
	end
	
	function p:r_col()
		return {
			self.x+6,
			self.y+3,
			self.x+7,
			self.y+4
		}
	end
	
	function p:d_col()
		return {
			self.x+3,
			self.y+6,
			self.x+4,
			self.y+7
		}
	end
	
	function p:l_col()
		return {
			self.x,
			self.y+3,
			self.x+1,
			self.y+4
		}
	end

	function p:u_col()
		return {
			self.x+3,
			self.y,
			self.x+4,
			self.y+1
		}
	end
	
	function p:engage_col()
		return {
			self.x-1,
			self.y-1,
			self.x+8,
			self.y+8
		}
	end
	
	function p:nearby_walls(room)
		local walls = {}
		local m_id=room.map_id
		local offset=m_id*16
		local mfx=flr(self.x/8)
		local mfy=flr(self.y/8)
		local mcx=ceil(self.x/8)
		local mcy=ceil(self.y/8)
--		rect(mx*8,my*8,mx*8+8,my*8+8)
	 local	mfs=mget(mfx,mfy)
	 local	mcs=mget(mcx,mcy)
	 local mff=fget(mfs,0)
	 local mcf=fget(mcs,0)
	 if(mff)add(walls,{mfx*8,mfy*8})
	 if(mcf)add(walls,{mcx*8,mcy*8})
	 
	 return walls
	end

	function p:handle_col(r)
	 	
	 for w_col in all (r.walls) do
		 if(colliding(self:u_col(),w_col))
		 then self.y=w_col[4]+1
		 end
		 if(colliding(self:r_col(),w_col))
		 then self.x=w_col[1]-8
		 end
		 if(colliding(self:d_col(),w_col))
		 then self.y=w_col[2]-8
		 end
		 if(colliding(self:l_col(),w_col))
		 then self.x=w_col[3]+1
		 end
	 end
	end
	
	function p:update(room)
		self:handle_col(room)
		p.anim:set(p.st)
		p.anim:update()
	end
	
	function p:draw(room)
--		for r in all(room.walls) do
--			rect(r[1],r[2],r[3],r[4],7)
--		end
--		local uc=self:u_col()
--		local rc=self:r_col()
--		local dc=self:d_col()
--		local lc=self:l_col()
--		rect(uc[1],uc[2],uc[3],uc[4],7)
--		rect(rc[1],rc[2],rc[3],rc[4],9)
--		rect(dc[1],dc[2],dc[3],dc[4],10)
--		rect(lc[1],lc[2],lc[3],lc[4],11)
		self.anim:draw(self.x,self.y,self.right)
	end
	
	return p
end


function mk_cloak_npc(opt)
	local npc={
		x=opt.x,
		y=opt.y,
		txt=opt.txt or {},
		left=opt.left
	}

	function npc:col()
		return {
			npc.x,
			npc.y,
			npc.x+7,
			npc.y+7
		}
	end
	
	local ani_opt={
		anim_tbl={
			idle={
				{
					spr=2,
					time=15
				},
				{
				 spr=3,
				 time=10
			 }
			}
		},
		state='idle'
	}
	
	npc.anim=mk_animator(ani_opt)
	
	function npc:update()
		self.anim:update()
			
	end
	
	function npc:draw()
		self.anim:draw(self.x,self.y,self.left)
	end
	
	return npc
end
-->8
--utilities


----- constants -----
const={
	letter_width=4,
	letter_height=5,
	line_height=8,
	card_width=34,
	card_height=40
}


----- text -----


--center text position
--(line of text, options)
--desc:
--provides the x and y 
--coordinates to print a
--line of text in the center
--of a given space
function cent_txt_pos(txt,opt)
--opt {
--	x,	x position of space
--	y,	y position of space
--	w, width of space
--	h 	height of space
--)
	local o=opt or {}
	local x=o.x or 0
	local y=o.y or 0
	local w=o.w or 128
	local h=o.h or 128
	
	local cent_x
	local cent_y

	cent_x=cent_txt_x(txt,x,w)
	cent_y=cent_txt_y(tst,y,h)
	
	return{cent_x,cent_y}
end

--center text table position
--(table of text lines, options)
--desc:
--provides the x and y 
--coordinates to print a set of
--lines of text in the center
--of a given space
function cent_txt_tbl_pos(txt,opt)
--opt {
--	x,	x position of space
--	y,	y position of space
--	w, width of space
--	h 	height of space
--)
	local o=opt or {}
	local x=o.x or 0
	local y=o.y or 0
	local w=o.w or 128
	local h=o.h or 128

	local cent_pos
	local cent_y
	local lh = const.line_height

	cent_y=cent_txt_tbl_y(txt,y,h)
	cent_pos={}

	for i, txt_l in ipairs(txt) do
		local cent_x
		local ly_off--line y offset
		cent_x=cent_txt_x(txt_l,x,w)	
		ly_off=(i-1)*lh
		add(
			cent_pos,
			{cent_x,cent_y+ly_off}
		)
	end

	return cent_pos
end

--get center text y
--(text, space y, height y)
--desc:
--returns the y coordinate of
--a line of text centered in a
--space starting at the provided
--y and is as tall as the
--provided height
function cent_txt_y(txt,y,h)
	local lh = const.letter_height
 local dif_h=h-lh
 return y+dif_h/2
end

--center text table y
--(text table, space y, height y)
--desc:
--finds the y coordinate of a table
--of text lines in a space at the
--provided y coordinate and is
--as tall as the given height
function cent_txt_tbl_y(txt,y,h)
	local lh = const.line_height
	txt_h=#txt*lh
 dif_h=h-txt_h
 return y+dif_h/2
end

--get center text x
--(line of text, width of space)
function cent_txt_x(txt,x,w)
	local lw=const.letter_width
	local txt_lw -- text line width
	local dif_w -- width difference
	
	txt_lw=#txt*lw
 dif_w=w-txt_lw

	return x+dif_w/2
end

--get widest text line
--(text table)
function get_widest_txt_l(txt)
	local	widest_txt_l = txt[1]
	for l in all(txt) do
		if #l>widest_txt_l then
			widest_txt_l = l
		end
	end
	
	return widest_text_l
end

--center box
--(width,height,container box)
--desc:
--finds the x and y coordinates
--to set a box to to center
--it inside of a container
--container defaults to screen
function cent_box(w,h,cont)
	local c=cont or {}
	local cx=c.x or 0
	local cy=c.y or 0
	local cw=c.w or 128
	local ch=c.h or 128
	
	local diff_w
	local diff_h
	local cent_x
	local cent_y
	
	diff_w=cw-w
	diff_h=ch-h
	
	cent_x=cx+diff_w/2
	cent_y=cy+diff_h/2
	
	return{cent_x,cent_y}
end


----- animation -----


--make animatior
--(table of sprite ids)
--desc:
--creates an animation object
--that manages a single animation
function mk_animator(opt)
--opt = {
--af_tbl= animation frame table
--}
--animation frame={
--spr, -sprite id
--time,-frames to sit on animation
--}
--anim_tbl {
--state,
--af_tbl
--}
	local a = {} --animator
	a.anim_tbl=opt.anim_tbl
	a.st=opt.state or 'idle'
	a.cur_s=1 -- current sprite
	a.t_sta=timer--time stamp
	
	function a:set(st)
		if(st != self.st) then
			a.st=st
			a.cur_s=1
			a.t_sta=timer
		end
	end
	
	function a:update()
		local af--animation frame
		local a_tbl=self.anim_tbl
		local af_tbl = a_tbl[self.st]
		local t_sta=self.t_sta
		local t=timer
		
		af=af_tbl[self.cur_s]
		if(t-t_sta>af.time)then 
			self.cur_s+=1
			self.t_sta=t
			if(self.cur_s>#af_tbl)then
				self.cur_s=1
			end
		end
	end
	
	function a:draw(x,y,left,sw,sh)
		local w=sw or 1
		local h=sh or 1
		local a_tbl=self.anim_tbl
		local af_tbl = a_tbl[self.st]
		local af
		af=af_tbl[self.cur_s]
		spr(af.spr,x,y,w,h,left)
	end
	
	return a
	
end


----- colliding -----


function colliding(box1,box2)
 return  box1[1] <= box2[3] and
   					 box1[2] <= box2[4] and
   					 box1[3] >= box2[1] and
   					 box1[4] >= box2[2]
end


----- tables -----


function copy_tbl_into(src,tar)
	for i=1,#src do
		add(tar,src[i])
	end
end


----- text box -----

function mk_diag(p,txt)
	local h = 36
	local bot = p.y<64
	local y = 2
	local ey= h
	if(bot)then
	 y=124-h
		ey=122
	end
	
	local diag={
		txt=txt,
		cur=1
	}
	
	function diag:draw()
		local marg=6
		rectfill(8,y,120,ey,0)
		rect(8,y,120,ey,7)
		for i,txt_l in ipairs(self.txt[self.cur]) do
		 local txt_x=8+marg
		 local txt_y=(8*(i-1))+y+marg
		 print(txt_l,txt_x,txt_y)
		end
	end
	
	return diag
end

function draw_stats(ent)
	local h = 26
	local x = 8
	local y = 2
	local marg=6
	local lh=const.letter_width
	local lih=const.line_height
	
	rectfill(x,y,120,h,0)
	rect(x,y,120,h,7)
	local hp_str
	hp_str=ent.hp.."/"..ent.maxhp
	local hp_str_w=#hp_str*lh
	print(ent.name,x+marg,y+marg,12)
	print(hp_str,x+marg,y+marg+lih,7)	
	print(" ♥",x+marg+hp_str_w,y+marg+lih,8)	
end
-->8
--type def


----- box -----


--	x,	x position of box
--	y,	y position of box
--	w, width of box
--	h 	height of box


-->8
--combat state
--make grid square
--create grids
function mk_combat_st()
	local st={}
	st.pg=mk_grid( --player grid
		{
			x=10,
			y=30,
			ents={mk_hero()},
--			sel=5
		}
	)
	st.eg=mk_grid({ --enemy grid
		x=70,
		y=30,
		ents={
			mk_robe()
		}
	})
	st.party=mk_c_party()
	st.hand=mk_hand()
	
	function st:update()
		st.cont:update(self)
		self.pg:update()
		self.eg:update()
	end
	
	function st:draw()
		rectfill(0,0,128,128,1)
		self.pg:draw(self)
		self.eg:draw(self)
		self.hand:draw()
--		draw_card(20,85,self.hand.cards[1])
	end
	
	function st.mk_combat_cont()
		local cont={
			st='sel_c',
			st_conts={}
		}
		function cont:set(st)
			if(self.st!=st)then
				self.st=st
			end
		end
		
		function cont:update(a_st)
			local cont 
			cont=self.st_conts[self.st]
			cont(self,a_st)
		end
		
		function cont.st_conts:sel_c(a_st)
			local hand=a_st.hand
			if(btnp(⬆️) or btnp(➡️))then
			 hand.sel+=1
			 if(hand.sel>#hand.cards)then
			 	hand.sel=1
			 end
			end
			if(btnp(⬅️) or btnp(⬇️))then
				hand.sel-=1
				if(hand.sel<1)then
			 	hand.sel=#hand.cards
			 end
			end
			
			if(btnp(🅾️))then
				a_st.cont:set('sel_t')
				a_st.tar_t=a_st.eg
			end
			
			if(btnp(❎))then
				a_st.cont:set('sel_g')
				a_st.hand.sel=nil
				a_st.pg.sel=5
				a_st.tar_t=a_st.pg
			end
		end

		function	cont.st_conts:sel_g(a_st)
			local t=a_st.tar_t
			local eg=a_st.eg
			local pg=a_st.pg
			local sel=t.sel
			if(btnp(⬆️)and sel>3)then
			 t.sel-=3
			end
			if(btnp(➡️))then
				if(sel%3==0)then
					if(t==pg)then
						local cs=sel
						t.sel=nil
						a_st.tar_t=eg
						t=eg
						t.sel=cs-2
					end
				else
					t.sel+=1
				end
			end
			if(btnp(⬇️)and sel<7)then
				t.sel+=3
			end
			if(btnp(⬅️))then
				if(sel==1
					or sel==4
					or sel==7
				)then
					if(t==eg)then
						local cs=sel
						t.sel=nil
						a_st.tar_t=pg
						t=pg
						t.sel=cs+2
					end
				else
					t.sel-=1
				end
			end
			if(btnp(❎))then
				a_st.hand.sel=1
				a_st.tar_t.sel=nil
				a_st.cont.st='sel_c'
				a_st.tar_t=nil
			end
			
		end
		
		function cont.st_conts:sel_t(a_st)
			local t=a_st.tar_t
			local pg=a_st.pg
			local eg=a_st.eg
			if(btnp(➡️) and t==pg)then
				a_st.tar_t=eg
			end
			if(btnp(⬅️) and t==eg)then
				a_st.tar_t=pg
			end
			if(btnp(🅾️))then
				
			end
			if(btnp(❎))then
				a_st.tar_t=nil
				a_st.cont.st='sel_c'
			end
		end
		
		function	cont.st_conts:diag(a_st)
--			local d = a_st.diag
--			if(btnp(🅾️)) d.cur+=1
--			if(d.cur>#d.txt)then
--				cont:set('walk')
--				a_st.diag=nil
--			end
		end		
		return cont
	end
	
	st.cont=st:mk_combat_cont()
	return st
end

function mk_grid(opt)
	local grid={
		x=opt.x,
		y=opt.y,
		ents=opt.ents or {}
	}
	grid.sel=opt.sel
	
	function grid:update()
		for ent in all(self.ents) do
			ent:update()
		end
	end
	
	function grid:draw(a_st)
		local x=self.x
		local y=self.y
		local sel=self.sel
		local is_tar=a_st.tar_t==self
		local dir
		local cards
		local sel_c
		cards=a_st.hand.cards
		sel_c=a_st.hand.sel
		
		if(is_tar)y=y-3
		draw_grid(x,y,is_tar)
		draw_sel(x,y,sel)
		if(is_tar and sel_c)then
			print(cards[sel_c])
			for t in all(cards[sel_c].tar) do
				local s
				local coord = g_pos_coord(x,y,t.pos)
				if(t.ef=="atk")s=72
				if(t.ef=="heal")s=74
				if(t.ef=="move")then 
					s=76
					dir=t.dir
				end
				spr(s,coord[1],coord[2],2,2)
				if(dir==➡️)then
					spr(78,coord[1],coord[2],2,2)
				end
				if(dir==⬇️)then
					spr(110,coord[1],coord[2],2,2,false,true)
				end			
				if(dir==⬅️)then
					spr(78,coord[1],coord[2],2,2,true)
				end			
				if(dir==⬆️)then
					spr(110,coord[1],coord[2],2,2)
				end						
			end	
		end
		
		for ent in all(self.ents) do
			draw_ent(x,y,ent)
			if(ent.pos==sel)then
				draw_stats(ent)
			end
		end
	end

	return grid
end


function draw_ent(x,y,ent)
	local coord
	coord=g_pos_coord(x,y,ent.pos)
	ent:draw(coord[1],coord[2])
end

function draw_grid(x,y,is_tar)
	palt(0,false)
	thicken_row(x,y,0)
	thicken_row(x,y+18,5)
	thicken_row(x,y+36,6)
	draw_column(x,y)
	draw_column(x+16,y)
	draw_column(x+32,y)
	if(is_tar)then
		rectfill(x-2,y+53,x+49,y+58,0)
	end
	rectfill(x-1,y+53,x+48,y+54,6)
	palt(0,true)
end

function draw_column(x,y)
	spr(64,x,y,2,2)
	spr(96,x,y+16,2,2)
	spr(66,x,y+18,2,2)
	spr(98,x,y+34,2,2)
	spr(68,x,y+36,2,2)
end

function thicken_row(x,y,col)
	rect(x-1,y-1,x+48,y+16,col)
end

function draw_sel(x,y,sel)
	if(not sel) return
	local coord
	local sx
	local sy
	coord = g_pos_coord(x,y,sel)
	sx=coord[1]
	sy=coord[2]
	
	spr(70,sx,sy,2,2)
	rect(sx-1,sy-1,sx+16,sy+16,10)
	
end

function g_pos_coord(x,y,pos)
	local coord_x
	local coord_y
	if(pos==1) then
		coord_x=x
		coord_y=y
	end
	if(pos==2) then
		coord_x=x+16
		coord_y=y
	end
	if(pos==3) then
		coord_x=x+32
		coord_y=y
	end
	if(pos==4) then
		coord_x=x
		coord_y=y+18
	end
	if(pos==5) then
		coord_x=x+16
		coord_y=y+18
	end
	if(pos==6) then
		coord_x=x+32
		coord_y=y+18
	end
	if(pos==7) then
		coord_x=x
		coord_y=y+36
	end
	if(pos==8) then
		coord_x=x+16
		coord_y=y+36
	end
	if(pos==9) then
		coord_x=x+32
		coord_y=y+36
	end
	
	return {coord_x,coord_y}
end

function draw_card(x,y,card)
	rectfill(x,y,x+34,y+40,4)
	rect(x,y,x+34,y+40,9)
	
	local cx
	local cw=const.card_width
	cx=cent_txt_x(card.title,x,cw)
	print(card.title,cx,y+4)
	
	for pos=1,9 do
		local coord
		coord=sum_pos_coord(x+8,y+19,pos)
		rect(coord[1],coord[2],coord[1]+6,coord[2]+6,5)
	end
	
	local tar = card.tar
	for t in all(tar) do
		local coord
		local c
		if(t.ef=='atk')c=8
		if(t.ef=='heal')c=11
		
		if(t.ef=='move')c=14
		coord=sum_pos_coord(x+8,y+19,t.pos)
		rectfill(coord[1],coord[2],coord[1]+6,coord[2]+6,c)
		rect(coord[1],coord[2],coord[1]+6,coord[2]+6,5)
		if(t.ef=='move')then
			local arrow_pos
			if(t.dir==⬆️)then
				pset(coord[1]+2,coord[2]+3,8)
				pset(coord[1]+3,coord[2]+2,8)
				pset(coord[1]+4,coord[2]+3,8)
			end
			if(t.dir==➡️)then
				pset(coord[1]+3,coord[2]+2,8)
				pset(coord[1]+4,coord[2]+3,8)
				pset(coord[1]+3,coord[2]+4,8)
			end
			if(t.dir==⬇️)then
			 pset(coord[1]+2,coord[2]+3,8)
				pset(coord[1]+3,coord[2]+4,8)
				pset(coord[1]+4,coord[2]+3,8)
			end
			if(t.dir==⬅️)then
				pset(coord[1]+3,coord[2]+2,8)
				pset(coord[1]+2,coord[2]+3,8)
				pset(coord[1]+3,coord[2]+4,8)
			end
			
		end		
	end
end

function mk_hand(opt)
	local hand = {}
	hand.sel=1
	hand.cards={
		raze_c,
		punish_c,
		raze_c,
		beg_c,
		crook_c,
		scatter_c
	}
	function hand:draw()
		local ch=const.card_height
		local cw=const.card_width
		local w=10*#self.cards+cw
		local hand_x=(128-w)/2
		local sel_x
		
		for i,c in ipairs(self.cards) do
			local y = 105
			if(self.sel==i)then
			 sel_x=hand_x+(i-1)*10
			else 
				draw_card(hand_x+(i-1)*10,y,c)
			end
		end
		
		if(sel_x)then
			draw_card(sel_x,85,self.cards[self.sel])
		end	
	end
	
	return hand
end

function sum_pos_coord(x,y,pos)
	local coord_x
	local coord_y
	if(pos==1) then
		coord_x=x
		coord_y=y
	end
	if(pos==2) then
		coord_x=x+6
		coord_y=y
	end
	if(pos==3) then
		coord_x=x+12
		coord_y=y
	end
	if(pos==4) then
		coord_x=x
		coord_y=y+6
	end
	if(pos==5) then
		coord_x=x+6
		coord_y=y+6
	end
	if(pos==6) then
		coord_x=x+12
		coord_y=y+6
	end
	if(pos==7) then
		coord_x=x
		coord_y=y+12
	end
	if(pos==8) then
		coord_x=x+6
		coord_y=y+12
	end
	if(pos==9) then
		coord_x=x+12
		coord_y=y+12
	end
	
	return {coord_x,coord_y}
end

--we're really building the party
--here
function mk_c_party()
	local c_party={}--combat party
	local party=app_state.party
	local filled_pos={}
	for m in all(party) do
		local name=m.name
		local deck={}
		local attr={
			maxhp=m.maxhp,
			atk=m.atk,
			hand=m.hand
		}
		local c=c
		local pos = fill_pos(filled_pos)
		for e in all(m.eqp) do
			for c in all(e.cards) do
				add(deck,c)
			end
			for k,v in pairs(e.attr) do
				attr[k]+=v
			end
		end
		local pm ={
			name=name,
			deck=deck,
			attr=attr,
			hp=maxhp,
			pos=pos,
			c=c,
			anim=mk_animator({
				anim_tbl={
					idle={
						{
							spr=102,
							time=10,
						},
						{
						 spr=104,
						 time=15,
						}
					},
				}
			})
		}
		
	function pm:update()
		self.anim:update()
	end
	function pm:draw(x,y)
		palt(0,false)
		palt(2,true)
		self.anim:draw(x,y,false,2,2)
		palt(2,false)
		palt(0,true)
	end
	
		add(c_party,pm)
	end
	
	return c_party
end

function fill_pos(pos_tbl)
	local pos=flr(rnd(9))+1
	if(pos_tbl[pos])then
		return fill_pos(pos_tbl)
	else 
		pos_tbl[pos]=true
		return pos
	end
end
---card effects, dmg, heal
---select target
-->8
--combat entities

--function mk_c

function mk_hero()
	local h={
		name="porkronymus bosch",
		desc="i have been told i am a failure",
		eqp={
			helm=helms.fool,
			chest=chest_arm.routed,
			bracers=bracers.scorned,
			grieves=grieves.exile	
		},
--		hp=5,
		hand=2,
		atk=1,
		maxhp=1,
		c=12
	}
	
	function h:update()
		self.anim:update()
	end
	function h:draw(x,y)
		palt(0,false)
		palt(2,true)
		self.anim:draw(x,y,false,2,2)
		palt(2,false)
		palt(0,true)
	end
	
	return h
end

function mk_robe()
	local r={
		name='robed blasphemy',
		hp=3,
		maxhp=3,
		pos=3,
		anim=mk_animator({
			anim_tbl={
				idle={
					{
						spr=128,
						time=10
					},
					{
					 spr=130,
					 time=15
					}
				},
			}
		})
	}
	
	function r:update()
		self.anim:update()
	end
	function r:draw(x,y)
		palt(0,true)
		self.anim:draw(x,y,false,2,2)
		palt(0,false)
	end
	
	return r
end

--need
-- card obj
-- card controller
-- card selector
-- raise selected card

----- cards -----

raze_c={
	title="RAZE",
	tar={
		{pos=2,ef="atk"},
		{pos=5,ef="atk"},
		{pos=8,ef="atk"}
	}
}

punish_c={
	title="PUNISH",
	tar={
		{pos=2,ef="atk"},
		{pos=4,ef="atk"},
		{pos=5,ef="atk"},
		{pos=6,ef="atk"},
		{pos=8,ef="atk"}
	}
}

beg_c={
	title="BEG",
	tar={
		{pos=1,ef="heal"},
		{pos=3,ef="heal"},
		{pos=7,ef="heal"},
		{pos=9,ef="heal"},
	}
}

crook_c={
	title="CROOK",
	tar={
		{pos=5,ef="move",dir=➡️},
	}
}

scatter_c={
	title="SCATTER",
	tar={
		{pos=2,ef="move",dir=⬅️},
		{pos=5,ef="move",dir=➡️},
		{pos=8,ef="move",dir=⬅️},
	}
}

	
	
--bracers of the forsaker
--UNGOD
-->8
helms={
	fool={
		name='helm of the fool',
		cards={
			raze_c
		},
		attr={
			maxhp=1,
			hand=-1
		}
	}
}

chest_arm={
	routed={
		name='chest of the routed',
		cards={
			scatter_c,
			beg_c
		},
		attr={
			maxhp=1
		}
	}
}

bracers={
 scorned={
		name='bracers of the scorned',
		cards={
			punish_c
		},
		attr={
			maxhp=1,
			atk=1
		}
	}
}

grieves={
	exile={
		name='grieves of the exile',
		cards={
			crook_c
		},
		attr={
			maxhp=1
		}
	}
}
__gfx__
000000001111111100449900000000000000000000e00e0000e00e00000000000000000000000000000000000000000000000000000000000000000000000000
00000000116666110449aa900004499000e00e000cccccc00cccccc0000000000000000000000000000000000000000000000000000000000000000000000000
00700700165665614449119000449aa90cccccc0cceeecc0cceeecc000e00e000000000000000000000000000000000000000000000000000000000000000000
00077000166556614444990004449119cceeecc00ccccce00eccccc00cccccc00000000000000000000000000000000000000000000000000000000000000000
000770001665566144444000044449900cccccc00eccccc00ccccce0cceeecc00000000000000000000000000000000000000000000000000000000000000000
007007001656656144141000044444000ecccce000e00e0000e00e00eeccccee0000000000000000000000000000000000000000000000000000000000000000
0000000011666611444440000441410000e00e0000e0000000000e00e0cccc0e0000000000000000000000000000000000000000000000000000000000000000
0000000011111111444440004444444000e00e0000e0000000000e0000e00e000000000000000000000000000000000000000000000000000000000000000000
55515551000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11151115000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55515551000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11151115000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55515551000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11151115000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55515551000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11151115000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000555555555555555566666666666666669999999999999999eeeeeeeeeeeeeeee3333333333333333dddddddddddddddd0000000080000000
0000500505556660555565565666777566667667677777769999a99a9aaaaaa9eeee8ee8e888888e3333b33b3bbbbbb3ddddeddedeeeeeed0000000088000000
00500050555666605565556566677775667666767777777699a999a9aaaaaaa9ee8eee8e8888888e33b333b3bbbbbbb3ddedddedeeeeeeed0000000088800000
00000505556666505555565666777765666667677777777699999a9aaaaaaaa9eeeee8e88888888e33333b3bbbbbbbb3dddddedeeeeeeeed0000000088880000
0500505556666550565565666777766567667677777777769a99a9aaaaaaaaa9e8ee8e888888888e3b33b3bbbbbbbbb3deddedeeeeeeeeed8888888888888000
000505556666555055565666777766656667677777777776999a9aaaaaaaaaa9eee8e8888888888e333b3bbbbbbbbbb3dddedeeeeeeeeeed8888888888888800
00505556666555005565666777766655667677777777776699a9aaaaaaaaaa99ee8e8888888888ee33b3bbbbbbbbbb33ddedeeeeeeeeeedd8888888888888880
0505556666555050565666777766656567677777777776769a9aaaaaaaaaa9a9e8e8888888888e8e3b3bbbbbbbbbb3b3dedeeeeeeeeeeded8888888888888888
00555666655505005566677776665655667777777777676699aaaaaaaaaa9a99ee8888888888e8ee33bbbbbbbbbb3b33ddeeeeeeeeeededd8888888888888888
0555666655505000566677776665655567777777777676669aaaaaaaaaa9a999e8888888888e8eee3bbbbbbbbbb3b333deeeeeeeeeededdd8888888888888880
0556666555050050566777766656556567777777776766769aaaaaaaaa9a99a9e888888888e8ee8e3bbbbbbbbb3b33b3deeeeeeeeededded8888888888888800
0566665550500000567777666565555567777777767666669aaaaaaaa9a99999e88888888e8eeeee3bbbbbbbb3b33333deeeeeeeededdddd8888888888888000
0666655505005000577776665655655567777777676676669aaaaaaa9a99a999e8888888e8ee8eee3bbbbbbb3b33b333deeeeeeededdeddd0000000088880000
0666555050000000577766656555555567777776766666669aaaaaa9a9999999e888888e8eeeeeee3bbbbbb3b3333333deeeeeededdddddd0000000088800000
0665550500500000577666565565555567777767667666669aaaaa9a99a99999e88888e8ee8eeeee3bbbbb3b33b33333deeeeededdeddddd0000000088000000
0000000000000000555555555555555566666666666666669999999999999999eeeeeeeeeeeeeeee3333333333333333dddddddddddddddd0000000080000000
050505050505050556565656565656560800000000000000222e22222e2222222222222222222222000000000000000000000000000000000000000880000000
505050505050505065656565656565650080000000000000222eeccccee22222222e22222e222222000000000000000000000000000000000000008888000000
00000000000000000000000000000000080000000000000022cccccccccc2222222e22222e222222000000000000000000000000000000000000088888800000
00000000000000000000000000000000000000000000000022ccceeeeeccc222222eeccccee22222000000000000000000000000000000000000888888880000
00000000000000000000000000000000000000000000000022ccce0ee0ccccc222cccccccccc2222000000000000000000000000000000000008888888888000
00000000000000000000000000000000000000000000000022ccccccccccc22222ccceeeeeccc222000000000000000000000000000000000088888888888800
000000000000000000000000000000000000000000000000222ccccccccc222222ccce0ee0ccccc2000000000000000000000000000000000888888888888880
0000000000000000000000000000000000000000000000002222ccccccc2222222ccccccccccc222000000000000000000000000000000008888888888888888
00000000000000000000000000000000000000000000000022222dcdcd222222222ccccccccc2222000000000000000000000000000000000000888888880000
00000000000000000000000000000000000000000000000022eecccccccee2222222ccccccc22222000000000000000000000000000000000000888888880000
0000000000000000000000000000000000000000000000002e2ccccccccc2e2222eeddcdcddee222000000000000000000000000000000000000888888880000
000000000000000000000000000000000000000000000000222ccccccccc22222e2ccccccccc2e22000000000000000000000000000000000000888888880000
0000000000000000000000000000000000000000000000002222ccccccc2222222ccccccccccc222000000000000000000000000000000000000888888880000
0000000000000000000000000000000000000000000000002222dcccccd22222222ccccccccc2222000000000000000000000000000000000000888888880000
0000000000000000000000000000000000000000000000002222e2ddd2e22222222edcccccde2222000000000000000000000000000000000000888888880000
0000000000000000000000000000000000000000000000002222e22222e222222222e2ddd2e22222000000000000000000000000000000000000888888880000
00000099990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000922229000000000009999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00009222222900000000092222900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00092211122290000000922222290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00922222222229000009221112229000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09222222222222900092222222222900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999999999999990922222222222290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999999999999999999999999999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00022222222220009999999999999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00022222222220000022222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00022222222220000022222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00022222222220000022222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00022222222220000022222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00022222222220000022222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00022222222220000022222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00022222222220000022222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888eeeeee888777777888eeeeee888eeeeee888888888888888888888888888888888888888888888ff8ff8888228822888222822888888822888888228888
8888ee888ee88778877788ee888ee88ee888ee88888888888888888888888888888888888888888888ff888ff888222222888222822888882282888888222888
888eee8e8ee8777787778eeeee8ee8eeeee8ee88888e88888888888888888888888888888888888888ff888ff888282282888222888888228882888888288888
888eee8e8ee8777787778eee888ee8eeee88ee8888eee8888888888888888888888888888888888888ff888ff888222222888888222888228882888822288888
888eee8e8ee8777787778eee8eeee8eeeee8ee88888e88888888888888888888888888888888888888ff888ff888822228888228222888882282888222288888
888eee888ee8777888778eee888ee8eee888ee888888888888888888888888888888888888888888888ff8ff8888828828888228222888888822888222888888
888eeeeeeee8777777778eeeeeeee8eeeeeeee888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111d111ddd1ddd1ddd111111dd1d1d11dd1d111ddd11111ddd1d1d1dd111dd1ddd1ddd11dd1dd111dd1111111111111111111111111111111111111111
111111111d1111d11d111d1111111d111d1d1d111d111d1111111d111d1d1d1d1d1111d111d11d1d1d1d1d111111111111111111111111111111111111111111
1ddd1ddd1d1111d11dd11dd111111d111ddd1d111d111dd111111dd11d1d1d1d1d1111d111d11d1d1d1d1ddd1111111111111111111111111111111111111111
111111111d1111d11d111d1111111d11111d1d111d111d1111111d111d1d1d1d1d1111d111d11d1d1d1d111d1111111111111111111111111111111111111111
111111111ddd1ddd1d111ddd111111dd1ddd11dd1ddd1ddd11111d1111dd1d1d11dd11d11ddd1dd11d1d1dd11111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1ee111ee1eee1eee11ee1ee1111111111666166116661666117111711111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111111111161161611611161171111171111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e1e1111e111e11e1e1e1e111111111161161611611161171111171111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111111111161161611611161171111171111111111111111111111111111111111111111111111111111111111111111
1e1111ee1e1e11ee11e11eee1ee11e1e111116661666161616661161117111711111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111666166616661111116616661666166616661111111111111666161611111666166616661611166611111166166611711171111111111111111111111111
11111616161616161111161111611616116116111111177711111666161611111161116111611611161111111611116117111117111111111111111111111111
11111666166616661111166611611666116116611111111111111616166111111161116111611611166111111666116117111117111111111111111111111111
11111616161116111111111611611616116116111111177711111616161611111161116111611611161111111116116117111117111111111111111111111111
11111616161116111666166111611616116116661111111111111616161616661161166611611666166616661661116111711171111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1ee111ee1eee1eee11ee1ee1111111111616166616611666166616661171117111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111111111616161616161616116116111711111711111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e1e1111e111e11e1e1e1e111111111616166616161666116116611711111711111111111111111111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111111111616161116161616116116111711111711111111111111111111111111111111111111111111111111111111
1e1111ee1e1e11ee11e11eee1ee11e1e111116661166161116661616116116661171117111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111666166616661111116616661666166616661111161616661661166616661666117111711111111111111111111111111111111111111111111111111111
11111616161616161111161111611616116116111171161616161616161611611611171111171111111111111111111111111111111111111111111111111111
11111666166616661111166611611666116116611111161616661616166611611661171111171111111111111111111111111111111111111111111111111111
11111616161116111111111611611616116116111171161616111616161611611611171111171111111111111111111111111111111111111111111111111111
11111616161116111666166111611616116116661111116616111666161611611666117111711111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1ee111ee1eee1eee11ee1ee1111111111661166616661616117111711111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111111111616161616161616171111171111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e1e1111e111e11e1e1e1e111111111616166116661616171111171111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111111111616161616161666171111171111111111111111111111111111111111111111111111111111111111111111
1e1111ee1e1e11ee11e11eee1ee11e1e111116661666161616161666117111711111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111bb1b1111bb1171117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111b111b111b111711111711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111b111b111bbb1711111711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111b111b11111b1711111711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111bb1bbb1bb11171117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111666166616661111116616661666166616661111166116661666161611711171111111111111111111111111111111111111111111111111111111111111
11111616161616161111161111611616116116111171161616161616161617111117111111111111111111111111111111111111111111111111111111111111
11111666166616661111166611611666116116611111161616611666161617111117111111111111111111111111111111111111111111111111111111111111
11111616161116111111111611611616116116111171161616161616166617111117111111111111111111111111111111111111111111111111111111111111
11111616161116111666166111611616116116661111166616161616166611711171111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
82888222822882228888822888828228828288888888888888888888888888888888888888888888888888888222822882888882822282288222822288866688
82888828828282888888882888288828828288888888888888888888888888888888888888888888888888888882882882888828828288288282888288888888
82888828828282288888882888288828822288888888888888888888888888888888888888888888888888888822882882228828822288288222822288822288
82888828828282888888882888288828888288888888888888888888888888888888888888888888888888888882882882828828828288288882828888888888
82228222828282228888822282888222888288888888888888888888888888888888888888888888888888888222822282228288822282228882822288822288
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__gff__
0001010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110101010100110100110101010100101101010010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110101010101010100110101010100101101010101010101010100100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110101010101010100110101010100101101010101010101010100100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110101010100110100110101010100101101010101010101010100100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010110100110101010100101101010101001010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110101010010110101010101010101010101010100101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110101010010110101010101010101010100101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110010101010110100110101010100101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110101010100110100110101010100100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110101010101010100110010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110101010101010100110101010100100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110101010100110100110101010100100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010110100101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110101010101010101010101010100100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4041404140410040414041404100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051505150510050515051505100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4243424342430042434243424300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5253525352530052535253525300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4445444544450044454445444500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5455545554550054555455545500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000001745018450194501b4502c050204502a050244502705027450260502d4502405030450240503345034450344503445032450334500000000000000000000000000
