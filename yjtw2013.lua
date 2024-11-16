local extension = Package("yjtw2013")
extension.extensionName = "yjtw"

Fk:loadTranslationTable{
  ["yjtw2013"] = "台湾一将2013",
  ["tw"] = "台版",
}
local U = require "packages/utility/utility"

local caoang = General(extension, "tw__caoang", "wei", 4)
local tw__xiaolian = fk.CreateTriggerSkill{
  name = "tw__xiaolian",
  anim_type = "support",
  events = {fk.TargetConfirming},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target ~= player and data.card.trueName == "slash" and
      data.tos and #AimGroup:getAllTargets(data.tos) == 1 and (not data.from or data.from ~= player.id)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#tw__xiaolian-invoke::"..data.tos[1][1]..":"..data.card:toLogString())
  end,
  on_use = function(self, event, target, player, data)
    local to = data.tos[1][1]
    player.room:doIndicate(player.id, {to})
    TargetGroup:removeTarget(data.targetGroup, to)
    TargetGroup:pushTargets(data.targetGroup, player.id)
    data.extra_data = data.extra_data or {}
    data.extra_data.tw__xiaolian = {player.id, to}
  end,
}
local tw__xiaolian_trigger = fk.CreateTriggerSkill{
  name = "#tw__xiaolian_trigger",
  mute = true,
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if data.card.trueName == "slash" and data.extra_data and data.extra_data.tw__xiaolian and
      data.extra_data.tw__xiaolian[1] == player.id and data.damageDealt and data.damageDealt[player.id]
      and not player:isNude() and not player.dead then
      local to = player.room:getPlayerById(data.extra_data.tw__xiaolian[2])
      return not to.dead and to:getEquipment(Card.SubtypeDefensiveRide) == nil
    end
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForCard(player, 1, 1, true, "tw__xiaolian", true, ".", "#tw__xiaolian-card::"..data.extra_data.tw__xiaolian[2])
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.extra_data.tw__xiaolian[2])
    room:doIndicate(player.id, {to.id})
    local card = Fk:getCardById(self.cost_data[1], true)
    room:setCardMark(card, "tw__xiaolian", 1)
    --[[local card = Fk:cloneCard("jueying")
    card:addSubcards(self.cost_data)
    table.insertIfNeed(to.virtual_equips, card)]]
    room:moveCards({
      ids = self.cost_data,
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

  refresh_events = {fk.BeforeCardsMove},
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
}
local tw__xiaolian_filter = fk.CreateFilterSkill{
  name = "#tw__xiaolian_filter",
  card_filter = function(self, to_select, player)
    return to_select:getMark("tw__xiaolian") > 0 and
      table.contains(player.player_cards[Player.Equip], to_select.id)
  end,
  view_as = function(self, to_select)
    local card = Fk:cloneCard("jueying", to_select.suit, to_select.number)
    card.skillName = self.name
    return card
  end,
}
tw__xiaolian:addRelatedSkill(tw__xiaolian_trigger)
tw__xiaolian:addRelatedSkill(tw__xiaolian_filter)
caoang:addSkill(tw__xiaolian)
Fk:loadTranslationTable{
  ["tw__caoang"] = "曹昂",
  ["tw__xiaolian"] = "孝廉",
  [":tw__xiaolian"] = "當一名其他角色成為【殺】的唯一目標時，你可以將此【殺】轉移給你。此【殺】结算后，若你受到此【殺】的傷害，"..
  "你可以將一張牌當【絕影】置入其裝備區。",
  ["#tw__xiaolian-invoke"] = "孝廉：你可以将对 %dest 使用的%arg转移给你",
  ["#tw__xiaolian-card"] = "孝廉：你可以将一张牌当【绝影】置入 %dest 的装备区",
}

local xiahouba = General(extension, "tw__xiahouba", "shu", 4)
xiahouba.subkingdom = "wei"
local tw__yinqin = fk.CreateTriggerSkill{
  name = "tw__yinqin",
  anim_type = "special",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start
  end,
  on_cost = function(self, event, target, player, data)
    local choices = {"Cancel", "wei", "shu"}
    local all_choices = table.simpleClone(choices)
    table.removeOne(choices, player.kingdom)
    local choice = player.room:askForChoice(player, choices, self.name, "#tw__yinqin-invoke", nil, all_choices)
    if choice ~= "Cancel" then
      self.cost_data = choice
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:changeKingdom(player, self.cost_data, true)
  end,
}
local tw__baobian = fk.CreateTriggerSkill{
  name = "tw__baobian",
  mute = true,
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card and table.contains({"slash", "duel"}, data.card.trueName)
  end,
  on_cost = function(self, event, target, player, data)
    local prompt = ""
    if data.to.kingdom == player.kingdom then
      prompt = "#tw__baobian1-invoke"
    elseif data.to:getHandcardNum() > data.to.hp then
      prompt = "#tw__baobian2-invoke"
    end
    if prompt ~= "" then
      return player.room:askForSkillInvoke(player, self.name, nil, prompt.."::"..data.to.id)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if data.to.kingdom == player.kingdom then
      local n = data.to.maxHp - data.to:getHandcardNum()
      if n > 0 then
        data.to:drawCards(n, self.name)
      end
      return true
    else
      local n = data.to:getHandcardNum() - data.to.hp
      local cards = room:askForCardsChosen(player, data.to, n, n, "h", self.name)
      room:throwCard(cards, self.name, data.to, player)
    end
  end,
}
xiahouba:addSkill(tw__yinqin)
xiahouba:addSkill(tw__baobian)
Fk:loadTranslationTable{
  ["tw__xiahouba"] = "夏侯霸",
  ["tw__yinqin"] = "姻亲",
  [":tw__yinqin"] = "準備階段，你可以將勢力變為魏或蜀。",
  ["tw__baobian"] = "豹变",
  [":tw__baobian"] = "當你使用【殺】或【決鬥】造成傷害時，若你的勢力與其：相同，你可以防止此傷害，令其將手牌摸至體力上限；不同，你可以將其手牌棄至體力值。",
  ["#tw__yinqin-invoke"] = "姻亲：你可以改变势力",
  ["#tw__baobian1-invoke"] = "豹变：你可以防止对 %dest 造成的伤害，令其摸牌至体力上限",
  ["#tw__baobian2-invoke"] = "豹变：你可以将 %dest 手牌弃至体力值",
}

local zumao = General(extension, "tw__zumao", "wu", 4)
local tw__tijin = fk.CreateTriggerSkill{
  name = "tw__tijin",
  anim_type = "support",
  events = {fk.TargetSpecifying},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target ~= player and data.card.trueName == "slash" and
      data.tos and #AimGroup:getAllTargets(data.tos) == 1 and (data.tos[1][1] ~= player.id) and
      target:inMyAttackRange(player) and U.canTransferTarget(player, data)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#tw__tijin-invoke::"..data.tos[1][1]..":"..data.card:toLogString())
  end,
  on_use = function(self, event, target, player, data)
    local to = data.tos[1][1]
    player.room:doIndicate(player.id, {to})
    TargetGroup:removeTarget(data.targetGroup, to)
    TargetGroup:pushTargets(data.targetGroup, player.id)
    data.extra_data = data.extra_data or {}
    data.extra_data.tw__tijin = {player.id, target.id}
  end,
}
local tw__tijin_trigger = fk.CreateTriggerSkill{
  name = "#tw__tijin_trigger",
  mute = true,
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    return data.card.trueName == "slash" and data.extra_data and data.extra_data.tw__tijin and
      data.extra_data.tw__tijin[1] == player.id and not player.dead and
      data.extra_data.tw__tijin[2] == target.id and not target.dead and not target:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    local id = room:askForCardChosen(player, target, "he", "tw__tijin")
    room:throwCard({id}, "tw__tijin", target, player)
  end,
}
tw__tijin:addRelatedSkill(tw__tijin_trigger)
zumao:addSkill(tw__tijin)
Fk:loadTranslationTable{
  ["tw__zumao"] = "祖茂",
  ["tw__tijin"] = "替巾",
  [":tw__tijin"] = "當其他角色使用【殺】指定唯一目標時，若你在其攻擊範圍內，你可以將此【殺】轉移給你。此【殺】結算後，你棄置使用者一張牌。",
  ["#tw__tijin-invoke"] = "替巾：你可以将对 %dest 使用的%arg转移给你",
}

return extension
