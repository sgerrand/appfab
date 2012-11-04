# encoding: UTF-8
module IdeasHelper
  IdeaIcons = {
    bug:     'icon-fire',
    chore:   'icon-bar-chart',
    feature: 'icon-beaker',
  }

  def idea_kind_select_options
    options_for_select([
      [s_('Idea|Feature'), 'feature'],
      [s_('Idea|Chore'),   'chore'],
      [s_('Idea|Bug'),     'bug']
    ])
  end

  def idea_icon_for_kind(idea, options = {})
    classes = options.fetch(:class, '').split
    classes.push IdeaIcons[idea.kind.to_sym]
    content_tag(:i, '', options.merge(class: safe_join(classes.uniq, ' ')))
  end

  def idea_size_human(size)
    case size
    when 1 then s_('T-shirt size|XS')
    when 2 then s_('T-shirt size|S')
    when 3 then s_('T-shirt size|M')
    when 4 then s_('T-shirt size|L')
    end
  end

  def idea_size_human_long(size)
    case size
    when 1 then s_('T-shirt size|Extra-small')
    when 2 then s_('T-shirt size|Small')
    when 3 then s_('T-shirt size|Medium')
    when 4 then s_('T-shirt size|Large')
    end
  end

  def idea_status(idea)
    case idea.state
    when 'submitted'   then s_('Idea state|submitted')    
    when 'vetted'      then s_('Idea state|vetted')
    when 'voted'       then s_('Idea state|voted')
    when 'picked'      then s_('Idea state|picked')    
    when 'designed'    then s_('Idea state|designed')      
    when 'approved'    then s_('Idea state|approved')      
    when 'implemented' then s_('Idea state|implemented')        
    when 'signed_off'  then s_('Idea state|signed_off')        
    when 'live'        then s_('Idea state|live')
    end
  end

  def idea_size_type_name(field)
    case field.to_s
    when 'design_size'      then s_('Idea size|Design size')
    when 'development_size' then s_('Idea size|Development size')
    end
  end

  # +state+ is the target state of the action
  def idea_unavailable_action_tooptip(idea, state)
    if idea.is_state_in_future?(state)
      case state
      when :vetted
        s_('Tooltip|This idea cannot be vetted yet.')
      when :voted
        s_('Tooltip|This idea cannot be backed yet.')
      else
        s_('Tooltip|This idea cannot be marked as %{state} yet.') % { :state => state.to_s }
      end
    else
      case state
      when :vetted
        s_('Tooltip|This idea has already been vetted.')
      when :voted
        s_('Tooltip|This idea cannot be backed anymore.')
      else
        s_('Tooltip|This idea has already been %{state}.') % { :state => state.to_s }
      end
    end
  end

end

