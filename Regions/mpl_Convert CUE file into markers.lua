-- @version 1.01
-- @author MPL, edits by FishSatire
-- @website http://forum.cockos.com/showthread.php?t=188335
-- @description Convert CUE file into markers
-- @changelog
--    # sytnhax error
  
  for key in pairs(reaper) do _G[key]=reaper[key]  end  
  local scr ='Convert CUE file into markers'
  ----------------------------------------------------
  function msg(s) 
    if not s then return end 
    ShowConsoleMsg(s..'\n')  
  end
  ----------------------------------------------------
  function main(fp)
    -- check file
      local f = io.open(fp, 'r')
      if not f then return end
      content = f:read('a')
      f:close()
    -- collect content
      local t, id = {}, 0
      for data in content:gmatch('[^\r\n]+') do 
        if data:find('TRACK ') then id = id +1 end -- without space after TRACK, ReplayGain_TRACK_GAIN breaks script
        if not t[id] then t[id] = '' end
        t[id] = t[id]..data 
      end
    -- parse data
      regt = {}
      for i = 1, #t do
        local time = t[i]:match('INDEX 01 ([%d%p]+)') -- specify Index 01, not pre-Index 00
        local pos = 0
        if time:match('[%d]+%:[%d]+%:[%d]+') then
          pos = time:match('([%d]+)%:[%d]+%:[%d]+')*60 + time:match('[%d]+%:([%d]+)%:[%d]+') + time:match('[%d]+%:[%d]+%:([%d]+)')/75 -- 75 frames in a CD not 100
        end
        regt[i] = {title = t[i]:match('TITLE "(.-)"'),
                   pos = pos} -- remove Performer as it's not always included, could use if statement
      end
    --  add markers
      for i = 1, #regt do AddProjectMarker( 0, false, regt[i].pos, -1, regt[i].title, -1 ) end -- removed performer
      UpdateTimeline()
  end
  retval, fn =  GetUserFileNameForRead('', scr, '.cue' )
  if retval then 
    reaper.Undo_BeginBlock()
    main(fn)
    reaper.Undo_EndBlock(scr, 1)
  end
