local tw__tijin = fk.CreateSkill {
  name = "tw__tijin"
}

Fk:loadTranslationTable{
  ['tw__tijin'] = '替巾',
  ['#tw__tijin-invoke'] = '替巾：你可以将对 %dest 使用的%arg转移给你',
  [':tw__tijin'] = '當其他角色使用【殺】指定唯一目標時，若你在其攻擊範圍內，你可以將此【殺】轉移給你。此【殺】結算後，你棄置使用者一張牌。',
}

tw__tijin:addEffect(fk.TargetSpecifying, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(tw__tijin.name) and target ~= player and data.card.trueName == "slash" and
         data.tos and #AimGroup:getAllTargets(data.tos) == 1 and (data.tos[1][1] ~= player.id) and
         target:inMyAttackRange(player) and U.canTransferTarget(player, data)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {skill_name = tw__tijin.name, prompt = "#tw__tijin-invoke::"..data.tos[1][1]..":"..data.card:toLogString()})
  end,
  on_use = function(self, event, target, player, data)
    local to = data.tos[1][1]
    player.room:doIndicate(player.id, {to})
    TargetGroup:removeTarget(data.targetGroup, to)
    TargetGroup:pushTargets(data.targetGroup, player.id)
    data.extra_data = data.extra_data or {}
    data.extra_data.tw__tijin = {player.id, target.id}
  end,
})

tw__tijin:addEffect(fk.CardUseFinished, {
  name = "#tw__tijin_trigger",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return data.card.trueName == "slash" and data.extra_data and data.extra_data.tw__tijin and
         data.extra_data.tw__tijin[1] == player.id and not player.dead and
         data.extra_data.tw__tijin[2] == target.id and not target.dead and not target:isNude()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    local id = room:askToChooseCard(player, {
      target = target,
      flag = "he",
      skill_name = "tw__tijin"
    })
    room:throwCard({id}, "tw__tijin", target, player)
  end,
})

return tw__tijin