--- STEAMODDED HEADER
--- MOD_NAME: Better Joker Collection
--- MOD_ID: better_joker_collection
--- MOD_AUTHOR: [Timooo]
--- MOD_DESCRIPTION: Adds sorting and searching to the joker collection

----------------------------------------------
------------MOD CODE -------------------------

-- Variables

bjc_option_cycle_state = 1
bjc_current_page = 1

bjc_settings = {
    sort_desc = false,
    ignore_undiscovered = false
}

-- Callbacks

G.FUNCS.bjc_change_sorting_type = function(args)
  bjc_option_cycle_state = args.to_key
  bjc_update_your_collection_joker_page(bjc_current_page)
end

G.FUNCS.your_collection_joker_page = function(args)
  if not args or not args.cycle_config then return end
  bjc_current_page = args.cycle_config.current_option
  bjc_update_your_collection_joker_page(bjc_current_page)
end

G.FUNCS.bjc_update_after_toggle = function()
  bjc_update_your_collection_joker_page(bjc_current_page)
end

-- Helper Functions

function bjc_update_your_collection_joker_page(page)
  for j = 1, #G.your_collection do
    for i = #G.your_collection[j].cards,1, -1 do
      local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
      c:remove()
      c = nil
    end
  end

  for i = 1, 5 do
    for j = 1, #G.your_collection do
      local center = bjc_get_joker(bjc_option_cycle_state, i+(j-1)*5 + (5*#G.your_collection*(page - 1)))
      if not center then break end
      local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
      card.sticker = get_joker_win_sticker(center)
      G.your_collection[j]:emplace(card)
    end
  end

  INIT_COLLECTION_CARD_ALERTS()
end

function clone_and_sort(pool, sorter)
    local t = {}
    for i=1,#pool do
        t[i] = pool[i]
    end
    table.sort(t, sorter)
    return t
end

function bjc_sort_by_order(a, b)
    if bjc_settings.ignore_undiscovered and a.discovered and not b.discovered then return true end
    if bjc_settings.ignore_undiscovered and b.discovered and not a.discovered then return false end
    if bjc_settings.sort_desc then return a.order > b.order end
    return a.order < b.order
end

function bjc_sort_by_name(a, b)
  if bjc_settings.ignore_undiscovered and a.discovered and not b.discovered then return true end
  if bjc_settings.ignore_undiscovered and b.discovered and not a.discovered then return false end
  if bjc_settings.sort_desc then return a.name > b.name end
  return a.name < b.name
end

function bjc_sort_by_sticker(a, b)
    if bjc_settings.ignore_undiscovered and a.discovered and not b.discovered then return true end
    if bjc_settings.ignore_undiscovered and b.discovered and not a.discovered then return false end
    a_sticker = get_joker_win_sticker(a, true)
    b_sticker = get_joker_win_sticker(b, true)
    if bjc_settings.sort_desc then return a_sticker > b_sticker end
    return a_sticker < b_sticker
end

function bjc_sort_by_rarity(a, b)
    if bjc_settings.ignore_undiscovered and a.discovered and not b.discovered then return true end
    if bjc_settings.ignore_undiscovered and b.discovered and not a.discovered then return false end
    if bjc_settings.sort_desc then return a.rarity > b.rarity end
    return a.rarity < b.rarity
end

function bjc_get_joker(sorting_type, index)
  if sorting_type == 1 then
    local sorted = clone_and_sort(G.P_CENTER_POOLS["Joker"], bjc_sort_by_order)
    return sorted[index]
  end
  if sorting_type == 2 then
    local sorted = clone_and_sort(G.P_CENTER_POOLS["Joker"], bjc_sort_by_name)
    return sorted[index]
  end
  if sorting_type == 3 then
    local sorted = clone_and_sort(G.P_CENTER_POOLS["Joker"], bjc_sort_by_sticker)
    return sorted[index]
  end
  if sorting_type == 4 then
    local sorted = clone_and_sort(G.P_CENTER_POOLS["Joker"], bjc_sort_by_rarity)
    return sorted[index]
  end
end

-- Overwriting original UI function

function create_UIBox_your_collection_jokers()
  local deck_tables = {}

  G.your_collection = {}
  for j = 1, 3 do
    G.your_collection[j] = CardArea(
      G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
      5*G.CARD_W,
      0.95*G.CARD_H, 
      {card_limit = 5, type = 'title', highlight_limit = 0, collection = true})
    table.insert(deck_tables, 
    {n=G.UIT.R, config={align = "cm", padding = 0.07, no_fill = true}, nodes={
      {n=G.UIT.O, config={object = G.your_collection[j]}}
    }}
    )
  end

  local joker_options = {}
  for i = 1, math.ceil(#G.P_CENTER_POOLS.Joker/(5*#G.your_collection)) do
    table.insert(joker_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#G.P_CENTER_POOLS.Joker/(5*#G.your_collection))))
  end

  for i = 1, 5 do
    for j = 1, #G.your_collection do
      local center = bjc_get_joker(bjc_option_cycle_state, i+(j-1)*5)
      if not center then break end
      local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, nil, center)
      card.sticker = get_joker_win_sticker(center)
      G.your_collection[j]:emplace(card)
    end
  end

  INIT_COLLECTION_CARD_ALERTS()
  
  local t = create_UIBox_generic_options({ back_func = 'your_collection', contents = {
        {n=G.UIT.C, config = {align = "cm"}, nodes = {
            {n=G.UIT.R, config = {align = "tm"}, nodes = {
                {n=G.UIT.C, config={align = "tl", r = 0.1, colour = G.C.BLACK, emboss = 0.05, w = 4.5, h = 4.1}, nodes=deck_tables},

                {n=G.UIT.C, config = {align = "cl", padding = 0.1, w = 2.7}, nodes = {
                    {n=G.UIT.R, config = {align = "tm", padding = 0.1}, nodes = {
                        {n=G.UIT.T, config={text="Better Joker Collection", colour=G.C.UI.TEXT_LIGHT, scale=0.5}},
                        {n=G.UIT.T, config={text="by Timooo", colour=G.C.MONEY, scale=0.3}}
                    }},
                    create_option_cycle({label = 'Sort By:', scale = 0.8, options = {'Default', 'Alphabet', 'Sticker', 'Rarity'}, opt_callback = 'bjc_change_sorting_type', current_option = bjc_option_cycle_state}),
                    create_toggle({label = "Descending Order", ref_table = bjc_settings, ref_value = 'sort_desc', callback = G.FUNCS.bjc_update_after_toggle}),
                    create_toggle({label = "Discovered Only", ref_table = bjc_settings, ref_value = 'ignore_undiscovered', callback = G.FUNCS.bjc_update_after_toggle}),
                    create_option_cycle({options = joker_options, w = 2.5, cycle_shoulders = true, opt_callback = 'your_collection_joker_page', current_option = 1, colour = G.C.RED, no_pips = true, focus_args = {snap_to = true, nav = 'wide'}})
                }}
            }}
        }}
    }})
  return t
end

----------------------------------------------
------------MOD CODE END----------------------