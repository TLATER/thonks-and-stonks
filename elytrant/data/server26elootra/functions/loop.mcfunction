#
#called by: elootra:load
#function elootra:loop
#

execute if entity @e[type=minecraft:item_frame,tag=!elo_tagged] run function server26elootra:check_frame
schedule function server26elootra:load 2t replace