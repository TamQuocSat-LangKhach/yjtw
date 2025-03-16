local tw__yinqin = fk.CreateSkill {
  name = "tw__yinqin"
}

Fk:loadTranslationTable{
  ['tw__yinqin'] = '姻亲',
  ['#tw__yinqin-invoke'] = '姻亲：你可以改变势力',
  [':tw__yinqin'] = '準備階段，你可以將勢力變為魏或蜀。',
}

tw__yinqin:addEffect(fk.EventPhaseStart, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tw__yinqin.name) and player.phase == Player.Start
  end,
  on_cost = function(self, event, target, player, data)
    local choices = {"Cancel", "wei", "shu"}
    local all_choices = table.simpleClone(choices)
    table.removeOne(choices, player.kingdom)
    local choice = player.room:askToChoice(player, {
    choices = choices,
    skill_name = tw__yinqin.name,
    prompt = "#tw__yinqin-invoke",
    all_choices = all_choices
    })
    if choice ~= "Cancel" then
    event:setCostData(skill, choice)
    return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local new_kingdom = event:getCostData(skill)
    player.room:changeKingdom(player, new_kingdom, true)
  end,
})

return tw__yinqin