#
#called by: elootra:loop
#execute if entity @e[type=minecraft:item_frame,tag=!elo_tagged] run function elootra:check_frame
#

execute as @e[type=minecraft:item_frame,tag=!elo_tagged,nbt={Item:{id: "minecraft:elytra"}}] run data merge entity @s {Item:{id:"minecraft:written_book",tag:{display: {Name: '{"text": "Elytra", "color": "yellow", "italic": false}'}, pages: ['{"text": "Because Will dislikes fun"}'], title: "Elytra", author: "Your Mom"}}}
tag @e[type=minecraft:item_frame,tag=!elo_tagged] add elo_tagged