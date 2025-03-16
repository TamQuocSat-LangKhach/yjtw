local tw__xiaolian = fk.CreateSkill {
  name = "tw__xiaolian"
}

Fk:loadTranslationTable{
  ['tw__xiaolian'] = '孝廉',
  ['#tw__xiaolian-invoke'] = '孝廉：你可以将对 %dest 使用的%arg转移给你',
  ['#tw__xiaolian-card'] = '孝廉：你可以將一張牌當【絕影】置入 %dest 的裝備區',
  [':tw__xiaolian'] = '當一名其他角色成為【殺】的唯一目標時，你可以將此【殺】轉移給你。此【殺】结算后，若你受到此【殺】的傷害，你可以將一張牌當【絕影】置入其裝備區。',
}

tw__xiaolian:addEffect(fk.TargetConfirming, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
  return player:hasSkill(skill.name) and target ~= player and data.card.trueName == "slash" and
    #AimGroup:getAllTargets(data.tos) == 1 and (not data.from or data.from ~= player.id)
  end,
  on_cost = function(self, event, target, player, data)
  return player.room:askToSkillInvoke(player, {
    skill_name = skill.name,
    prompt = "#tw__xiaolian-invoke::"..data.tos[1][1]..":"..data.card:toLogString()
  })
  end,
  on_use = function(self, event, target, player, data)
  local to = data.tos[1][1]
  player.room:doIndicate(player.id, {to})
  TargetGroup:removeTarget(data.targetGroup, to)
  TargetGroup:pushTargets(data.targetGroup, player.id)
  data.extra_data = data.extra_data or {}
  data.extra_data.tw__xiaolian = {player.id, to}
  end,
})

tw__xiaolian:addEffect(fk.CardUseFinished, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
  if data.card.trueName == "slash" and data.extra_data and data.extra_data.tw__xiaolian and
    data.extra_data.tw__xiaolian[1] == player.id and data.damageDealt and data.damageDealt[player.id]
    and not player:isNude() and not player.dead then
    local to = player.room:getPlayerById(data.extra_data.tw__xiaolian[2])
    return not to.dead and to:getEquipment(Card.SubtypeDefensiveRide) == nil
  end
  end,
  on_cost = function(self, event, target, player, data)
  local card = player.room:askToCards(player, {
    min_num = 1,
    max_num = 1,
    include_equip = true,
    skill_name = "tw__xiaolian",
    prompt = "#tw__xiaolian-card::"..data.extra_data.tw__xiaolian[2]
  })
  if #card > 0 then
    event:setCostData(skill.name, card)
    return true
  end
  end,
  on_use = function(self, event, target, player, data)
  local room = player.room
  local to = room:getPlayerById(data.extra_data.tw__xiaolian[2])
  room:doIndicate(player.id, {to.id})
  local card = Fk:getCardById(event:getCostData(skill.name)[1], true)
  room:setCardMark(card, "tw__xiaolian", 1)
  --[[local card = Fk:cloneCard("jueying")
  card:addSubcards(self.cost_data)
  table.insertIfNeed(to.virtual_equips, card)]]
  room:moveCards({
    ids = event:getCostData(skill.name),
    from = player.id,
    to = to.id,
    toArea = Card.PlayerEquip,
    moveReason = fk.ReasonPut,
    proposer = player.id,
    skillName = "tw__xiaolian",
  })
  if card.type == Card.TypeEquip then
    local skill = card.equip_skill
    room:handleAddLoseSkills(to, "-"..skill.name, nil, false, true)
  end
  end,

  can_refresh = function(self, event, target, player, data)
  for _, move in ipairs(data) do
    for _, info in ipairs(move.moveInfo) do
    if info.fromArea == Card.PlayerEquip and Fk:getCardById(info.cardId, true):getMark("tw__xiaolian") > 0 then
      return true
    end
    end
  end
  end,
  on_refresh = function(self, event, target, player, data)
  for _, move in ipairs(data) do
    for _, info in ipairs(move.moveInfo) do
    if info.fromArea == Card.PlayerEquip then
      player.room:setCardMark(Fk:getCardById(info.cardId, true), "tw__xiaolian", 0)
    end
    end
  end
  end,
})

tw__xiaolian:addEffect('filter', {
  card_filter = function(self, player, to_select)
  return to_select:getMark("tw__xiaolian") > 0 and
    table.contains(player.player_cards[Player.Equip], to_select.id)
  end,
  view_as = function(self, player, to_select)
  local card = Fk:cloneCard("jueying", to_select.suit, to_select.number)
  card.skillName = skill.name
  return card
  end,
})

return tw__xiaolian
