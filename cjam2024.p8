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
-->8
--life cycle functions

function _init()
	app_state = mk_title_st()
end

function _update()
	app_state:update()
end

function _draw()
	cls()
	app_state:draw()
end
-->8
--title state

function mk_title_st() 
	return {
		update=function(self)
			
		end,
		draw=function(self)
			local t -- title
			t="cabin jam 2024 project"
			local center_l_pos
			--center line positions
			clp=center_txt_pos(
				{t},
				0,
				0,
				128,
				128
			)
			--line position
			local l=clp[1]
			print(t,l[1],l[2])
		end
	}
end
-->8
--utilities


----- text -----


--constants
letter_width=4
letter_height=6
line_height = 8

--center text position
function center_txt_pos(
	txt, -- text table
	x, 		--	x position of space
	y, 		--	y position of space
	w, 		--	width of space
	h 			--	height of space
)
	-- center positions table
	local center_pos={}
	--text height
	local txt_h=#txt*line_height
	--height difference
	local dif_h=h-txt_h
	--center y
	local cy = y+dif_h/2
	
	--index, line of text
	for i, l in ipairs(txt) do
		--line width
		local	lw = #l*letter_width
		-- width difference
		local dif_w=w-lw
		-- center x
		local cx=x+dif_w/2
		add(
			center_pos,
			{cx,cy+((i-1)*line_height)}
		)
	end

	return center_pos
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
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
