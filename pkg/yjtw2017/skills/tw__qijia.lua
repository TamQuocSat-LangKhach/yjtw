local tw__qijia = fk.CreateSkill {
  name = "tw__qijia"
}

Fk:loadTranslationTable{
  ['tw__qijia'] = '弃甲',
  ['#tw__qijia'] = '弃甲：弃置一张本阶段未弃置过副类别的装备，视为使用不计次数的【杀】',
  [':tw__qijia'] = '出牌階段，你可以棄置裝備區內一張牌（每種副類別每階段限一次），視為對攻擊範圍內一名角色使用一張不計次數的【殺】。',
}

tw__qijia:addEffect('active', {
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
  prompt = "#tw__qijia",
  can_use = function(self, player)
  return #player:getCardIds("e") > 0
  end,
  card_filter = function(self, player, to_select, selected)
  if #selected == 0 and Fk:currentRoom():getCardArea(to_select) == Player.Equip then
    return player:getMark("tw__qijia_"..Fk:getCardById(to_select):getSubtypeString().."-phase") == 0
  end
  end,
  target_filter = function(self, player, to_select, selected)
  local target = Fk:currentRoom():getPlayerById(to_select)
  return #selected == 0 and player:inMyAttackRange(target) and not player:isProhibited(target, Fk:cloneCard("slash"))
  end,
  on_use = function(self, room, effect)
  local player = room:getPlayerById(effect.from)
  local target = room:getPlayerById(effect.tos[1])
  room:setPlayerMark(player, "tw__qijia_"..Fk:getCardById(effect.cards[1]):getSubtypeString().."-phase", 1)
  room:throwCard(effect.cards, player, player)
  room:useVirtualCard("slash", nil, player, target, tw__qijia.name, true)
  end,
})

return tw__qijia