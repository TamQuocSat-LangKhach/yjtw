local tw__rangyi = fk.CreateSkill {
  name = "tw__rangyi"
}

Fk:loadTranslationTable{
  ['tw__rangyi'] = '攘夷',
  ['#tw__rangyi'] = '攘夷：将所有手牌交给一名角色，其使用其中一张牌或你对其造成1点伤害',
  ['#tw__rangyi-use'] = '攘夷：你需使用其中一张牌并交还给 %src 其余的牌，否则其对你造成1点伤害',
  [':tw__rangyi'] = '出牌階段限一次，你可以將所有手牌交給一名其他角色，其選擇一項：1.使用其中一張牌，结算前交還給你其餘的牌；2.你對其造成1點傷害。',
}

tw__rangyi:addEffect('active', {
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#tw__rangyi",
  can_use = function(self, player)
  return not player:isKongcheng() and player:usedSkillTimes(tw__rangyi.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
  return false
  end,
  target_filter = function(self, player, to_select, selected)
  return #selected == 0 and to_select ~= player.id
  end,
  on_use = function(self, room, effect)
  local player = room:getPlayerById(effect.from)
  local target = room:getPlayerById(effect.tos[1])
  local cards = table.simpleClone(player:getCardIds("h"))
  local dummy1 = Fk:cloneCard("dilu")
  dummy1:addSubcards(cards)
  room:obtainCard(target.id, dummy1, false, fk.ReasonGive)
  if target.dead then return end
  local pattern = "^(jink,nullification)|.|.|.|.|.|"
  for _, id in ipairs(cards) do
    local card = Fk:getCardById(id)
    if not target:prohibitUse(card) and target:canUse(card) then
    pattern = pattern..id..","
    end
  end
  pattern = string.sub(pattern, 1, #pattern - 1)
  local use = room:askToUseCard(target, {
    skill_name = "",
    pattern = pattern,
    prompt = "#tw__rangyi-use:" .. player.id,
    cancelable = true
  })
  if use then
    if not player.dead then
    table.removeOne(cards, use.card:getEffectiveId())
    local dummy2 = Fk:cloneCard("dilu")
    dummy2:addSubcards(cards)
    room:obtainCard(player.id, dummy2, false, fk.ReasonGive)
    end
    room:useCard(use)
  else
    room:damage{
    from = player,
    to = target,
    damage = 1,
    skillName = tw__rangyi.name,
    }
  end
  end,
})

return tw__rangyi