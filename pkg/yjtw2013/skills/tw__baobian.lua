local tw__baobian = fk.CreateSkill {
  name = "tw__baobian"
}

Fk:loadTranslationTable{
  ['tw__baobian'] = '豹变',
  ['#tw__baobian1-invoke'] = '豹变：你可以防止对 %dest 造成的伤害，令其摸牌至体力上限',
  ['#tw__baobian2-invoke'] = '豹变：你可以将 %dest 手牌弃至体力值',
  [':tw__baobian'] = '當你使用【殺】或【決鬥】造成傷害時，若你的勢力與其：相同，你可以防止此傷害，令其將手牌摸至體力上限；不同，你可以將其手牌棄至體力值。',
}

tw__baobian:addEffect(fk.DamageCaused, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
  return target == player and player:hasSkill(tw__baobian.name) and data.card and table.contains({"slash", "duel"}, data.card.trueName)
  end,
  on_cost = function(self, event, target, player, data)
  local prompt = ""
  if data.to.kingdom == player.kingdom then
    prompt = "#tw__baobian1-invoke"
  elseif data.to:getHandcardNum() > data.to.hp then
    prompt = "#tw__baobian2-invoke"
  end
  if prompt ~= "" then
    return player.room:askToSkillInvoke(player, {
    skill_name = tw__baobian.name,
    prompt = prompt .. "::" .. data.to.id
    })
  end
  end,
  on_use = function(self, event, target, player, data)
  local room = player.room
  if data.to.kingdom == player.kingdom then
    local n = data.to.maxHp - data.to:getHandcardNum()
    if n > 0 then
    data.to:drawCards(n, tw__baobian.name)
    end
    return true
  else
    local n = data.to:getHandcardNum() - data.to.hp
    local cards = room:askToChooseCards(player, {
    min = n,
    max = n,
    target = data.to,
    flag = "h",
    skill_name = tw__baobian.name
    })
    room:throwCard(cards, tw__baobian.name, data.to, player)
  end
  end,
})

return tw__baobian