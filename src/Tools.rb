# -*- coding: utf-8 -*-
#==============================================================================
# ** RME V1.0.0
#------------------------------------------------------------------------------
#  With :
# Grim (original project)
# Nuki (a lot of things)
# Raho (general reformulation)
# Zeus81 (a lot of help)
# Hiino (some help and GUI Components)
# Joke (some help)
# Zangther (some help)
# XHTMLBoy (koffie)
# Fabien (Buzzer)
# Kaelar (Improvement)
#
#==============================================================================

=begin

License coming soon

=end

#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
#  This class performs the map screen processing.
#==============================================================================

class Scene_Map
  #--------------------------------------------------------------------------
  # * Alias
  #--------------------------------------------------------------------------
  alias_method :tools_update, :update
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    tools_update
    update_eval if $TEST
  end
  #--------------------------------------------------------------------------
  # * Update eval
  #--------------------------------------------------------------------------
  def update_eval

    if !@box && Keyboard.trigger?(RME::Config::KEY_EVAL)
      @old_call_menu = $game_system.menu_disabled
      $game_system.menu_disabled = true
      @box = Graphical_eval.new
    else
      if @box && Keyboard.any?(:trigger?, RME::Config::KEY_EVAL, :esc)
        @box.dispose
        Game_Temp.in_game = true
        @box = nil
        sleep(0.5)
        $game_system.menu_disabled = @old_call_menu
        return
      end
      @box.update if @box
    end

  end
end


class Graphical_eval

  def initialize
    Game_Temp.in_game = false
    @width = Graphics.width - 12
    @height = 58
    @text_h = @height - 16
    @x = 6
    @y = Graphics.height - @height - 6
    create_viewport
    create_background
    create_textfield
    create_marker
    create_buttons
  end

  def create_buttons
    start_x = @width - 140
    margin = 4
    button_width = (130 + 2*margin)/3
    font = get_profile("small_standard").to_font
    font.name = "Arial"
    font.color = Color.new(255, 255, 255)

    @copy = Sprite.new(@viewport)
    @copy.bitmap = Bitmap.new(button_width, @text_h - 20)
    @copy.bitmap.font = font
    @copy.bitmap.fill_rect(0, 0, button_width, @text_h-20, Color.new(0,0,0,180))
    @copy.x = start_x
    @copy.y = 15
    @copy.bitmap.draw_text(@copy.bitmap.rect, "As TXT", 1)
    start_x += button_width + 4

    @copy_ev = Sprite.new(@viewport)
    @copy_ev.bitmap = Bitmap.new(button_width, @text_h - 20)
    @copy_ev.bitmap.font = font
    @copy_ev.bitmap.fill_rect(0, 0, button_width, @height-20, Color.new(0,0,0,180))
    @copy_ev.x = start_x
    @copy_ev.y = 15
    @copy_ev.bitmap.draw_text(@copy_ev.bitmap.rect, "As EV", 1)
    start_x += button_width + 4

    @run = Sprite.new(@viewport)
    @run.bitmap = Bitmap.new(@width-start_x-4, @text_h - 20)
    @run.bitmap.font = font
    @run.bitmap.font.size = 20
    @run.bitmap.font.color = Color.new(0, 255, 0)
    @run.bitmap.fill_rect(0, 0, @width-start_x-4, @text_h-20, Color.new(0,0,0,180))
    @run.x = start_x
    @run.bitmap.draw_text(@run.bitmap.rect, "►", 1)
    @run.y = 15

    @background.bitmap.draw_text(@width - 142, 0, button_width, 10, "COPY")
    @background.bitmap.draw_text(start_x, 0,  @width-start_x-4, 10, "RUN")

  end

  def create_viewport
    @viewport = Viewport.new(@x, @y, @width, @height)
  end

  def create_textfield
    @textfield = Gui::Components::Text_Field.new(
                  Gui::Components::Text_Recorder.new, 8, 17, @width - 164,
                  "small_standard", true)
    @textfield >> @viewport
  end

  def create_background
    @background = Sprite.new(@viewport)
    @background.bitmap = Bitmap.new(@width, @height)
    rect = @background.bitmap.rect
    colorA = Color.new(83, 83, 83, 130)
    colorB = Color.new(36, 36, 36, 130)
    @background.bitmap.gradient_fill_rect(rect, colorA, colorB, true)
    @text_rect = Rect.new(6, 15, @width - 160, @text_h - 20)
    @background.bitmap.fill_rect(@text_rect, Color.new(255, 255, 255, 200))
    @background.bitmap.fill_rect(0, 0, @width, 12, Color.new(0, 0, 0, 200))
    @background.bitmap.font = get_profile("small_standard_title").to_font
    @background.bitmap.font.name = "Arial"
    @background.bitmap.font.size = 13
    @background.bitmap.draw_text(2, 0, @width, 10, "SCRIPT LINE")
    @background.bitmap.fill_rect(0, @text_h+2, @width, 14, Color.new(0, 0, 0, 140))
  end

  def create_marker
    @marker = Sprite.new(@viewport)
    @marker.bitmap = Bitmap.new(8,  @text_h - 20)
    @marker.x = @width - 160 + 6
    @marker.y = 15
    @marker.bitmap.fill_rect(0, 0, 8, @text_h-20, Color.new(50, 50, 50))
    valid_marker
  end

  def valid_marker
    @marker.tone.set(0, 255, 0)
  end

  def invalid_marker
    @marker.tone.set(255, 0, 0)
  end

  def update
    execute_command if Devices::Keys::Enter.trigger? && !@tabulate
    update_buttons
    update_tabulation if Devices::Keys::Tab.trigger?
    @textfield.update
  end

  def join_candidates
    (' '*4) + @stack.join(' '*4)
  end

  def join_current
    (' '*4) + @current_t
  end

  def create_tab_candidates
    @current_t = @stack.shift
    temp = Bitmap.new(1, 1)
    rect_tab = temp.text_size(join_current + join_candidates)
    temp.font = @background.bitmap.font.clone
    @candidates = Sprite.new(@viewport)
    @candidates.bitmap = Bitmap.new(rect_tab.width, rect_tab.height)
    @candidates.bitmap.font = temp.font.clone
    @candidates.x = 0
    @candidates.y = @text_h - 3
    update_tab_bitmap
  end

  def  update_tab_bitmap
    @candidates.bitmap.clear
    oth_rect = @candidates.bitmap.text_size(join_current)
    nve_rect = @candidates.bitmap.text_size(join_candidates)
    @candidates.bitmap.font.color = Color.new(0, 255, 0)
    @candidates.bitmap.draw_text(oth_rect, join_current)
    @candidates.bitmap.font.color = Color.new(255, 255, 255)
    @candidates.bitmap.draw_text(oth_rect.width, 0, nve_rect.width, nve_rect.height, join_candidates)
  end

  def remove_tab_candidates
    @candidates.dispose
  end

  def update_tabulation
    i = @textfield.virtual_position
    token = @textfield.formatted_value.extract_tokens(i-1)[-1]
    if token
      v = @textfield.formatted_value[i..-1]
      before = v[0...i] || ""
      after = v[i..-1] || ""
      if Command.singleton_methods.include?(token.to_sym)
        args = Command.method(token.to_sym).parameters.map  do |u|
          if u[0] == :rest then "*#{u[1]}"
          elsif u[0] == :opt then "?#{u[1]}"
          else
            u[1]
          end
        end
        res = (args.length == 0) ? "" : "(#{args.join(',')})"
        before += token + res
        @textfield.value = before + after
        @textfield.virtual_position = before.length
        @textfield.refresh
        return
      end
      token_len = token.length
      index = i-token_len
      before = index == 0 ? "" : @textfield.formatted_value[0..index-1]
      after = @textfield.formatted_value[i..-1]
      cmds = Command.singleton_methods.map(&:to_s)
      @stack = token.auto_complete(cmds)[0..3]
      create_tab_candidates
      loop do
        Graphics.update
        Input.update
        if Devices::Keys::Tab.trigger?
          @stack << @current_t
          @current_t = @stack.shift
          update_tab_bitmap
        end
        break if Devices::Keys::Esc.trigger?
        if Devices::Keys::Enter.trigger?
          before = before + @current_t
          @textfield.value = before + after
          @textfield.selection_start = @textfield.virtual_position = before.length
          @textfield.refresh
          break
        end
      end
      remove_tab_candidates
    end
  end

  def update_buttons
    if @copy.trigger?(:mouse_left)
      Clipboard.push_text(@textfield.formatted_value)
      msgbox("Script line pushed in the clipboard (as a text)")
    end
    if @copy_ev.trigger?(:mouse_left)
      rpg_command = RPG::EventCommand.new(355, 0, [@textfield.formatted_value])
      Clipboard.push_command(rpg_command)
      msgbox("Script line pushed in the clipboard (as an event's command)")
    end
    execute_command if @run.trigger?(:mouse_left)
  end

  def execute_command
    commands = @textfield.formatted_value
    begin
      eval(commands, $game_map.interpreter.get_binding)
      $game_map.need_refresh = true
      valid_marker
    rescue Exception => exc
      invalid_marker
      result = exc.message
      if exc.is_a?(NameError)
        keywords = Command.singleton_methods
        keywords.uniq!
        keywords.delete(:method_missing)
        keywords.collect!{|i|i.to_s}
        keywords.sort_by!{|o| o.damerau_levenshtein(exc.name)}
        snd = keywords.length > 1 ? " or [#{keywords[1]}]" : ""
        result = "[#{exc.name}] doesn't exist. Did you mean [#{keywords[0]}]"+snd+"?"
      elsif exc.is_a?(SyntaxError)
        result = exc.message.split(/\:\d+\:/)[-1].strip
      end
      msgbox result
    end
  end

  def dispose
    @textfield.dispose
    @viewport.dispose
  end

end
