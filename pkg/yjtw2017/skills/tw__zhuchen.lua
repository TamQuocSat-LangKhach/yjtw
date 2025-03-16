local tw__zhuchen = fk.CreateSkill {
  name = "tw__zhuchen"
}

Fk:loadTranslationTable{
  ['tw__zhuchen'] = '诛綝',
  ['#tw__zhuchen'] = '诛綝：弃置一张【桃】或【酒】，本阶段至一名角色距离视为1',
  [':tw__zhuchen'] = '出牌階段，你可以棄置一張【桃】或【酒】並指定一名其他角色，此階段你至其距離視為1。',
}

tw__zhuchen:addEffect('active', {
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
  prompt = "#tw__zhuchen",
  can_use = function(self, player)
    return not player:isKongcheng()
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains({"peach", "analeptic"}, Fk:getCardById(to_select).trueName)
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, tw__zhuchen.name, player, player)
    room:setPlayerMark(room:getPlayerById(effect.tos[1]), "tw__zhuchen-turn", player.id)
  end,
})

tw__zhuchen:addEffect('distance', {
  fixed_func = function(self, from, to)
  if to:getMark("tw__zhuchen-turn") == from.id then
    return 1
  end
  end,
})

return tw__zhuchen