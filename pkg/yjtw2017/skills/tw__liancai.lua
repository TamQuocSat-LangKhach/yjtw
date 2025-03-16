local tw__liancai = fk.CreateSkill {
  name = "tw__liancai"
}

Fk:loadTranslationTable{
  ['tw__liancai'] = '敛财',
  ['#tw__liancai-choose'] = '敛财：你可以翻面并获得一名角色装备区内一张牌',
  ['#tw__liancai-invoke'] = '敛财：你可以摸牌至体力值',
  [':tw__liancai'] = '結束階段開始時，你可以翻面並獲得一名角色裝備區內的一張牌。每當你翻面後，你可以將手牌摸至體力值。',
}

tw__liancai:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player)
    if target == player and player:hasSkill(tw__liancai.name) then
      return player.phase == Player.Finish and table.find(player.room.alive_players, function(p) return #p:getCardIds("e") > 0 end)
    end
  end,
  on_cost = function(self, event, target, player)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function(p)
      return #p:getCardIds("e") > 0 end), function (p) return p.id end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = table.map(table.filter(room.alive_players, function(p) return #p:getCardIds("e") > 0 end), function (p) return p.id end),
      prompt = "#tw__liancai-choose",
      skill_name = tw__liancai.name,
      cancelable = true
    })
    if #to > 0 then
      event:setCostData(skill, to[1])
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    player:turnOver()
    local to = room:getPlayerById(event:getCostData(skill))
    if not player.dead and not to.dead and #to:getCardIds("e") > 0 then
      local id = room:askToChooseCard(player, {
        target = to,
        flag = "e",
        skill_name = tw__liancai.name
      })
      room:obtainCard(player.id, id, true, fk.ReasonPrey)
    end
  end,
})

tw__liancai:addEffect(fk.TurnedOver, {
  can_trigger = function(self, event, target, player)
    if target == player and player:hasSkill(tw__liancai.name) then
      return player:getHandcardNum() < player.hp
    end
  end,
  on_cost = function(self, event, target, player)
    local room = player.room
    return room:askToSkillInvoke(player, {
      skill_name = tw__liancai.name,
      prompt = "#tw__liancai-invoke"
    })
  end,
  on_use = function(self, event, target, player)
    player:drawCards(player.hp - player:getHandcardNum(), tw__liancai.name)
  end,
})

return tw__liancai