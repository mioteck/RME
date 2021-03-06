# -*- coding: utf-8 -*-
#==============================================================================
# ** RME V1.0.0 Gui
#------------------------------------------------------------------------------
#  With :
# Joke
# Grim
# Nuki
#
#------------------------------------------------------------------------------
# Graphical User Interface SDK for RME's tools
#==============================================================================

=begin

License coming soon

=end

#==============================================================================
# ** Generative
#------------------------------------------------------------------------------
#  Mixins collection
#==============================================================================

module Generative

  #==============================================================================
  # ** Stackable
  #------------------------------------------------------------------------------
  #  Dad in Mom
  #==============================================================================

  module Stackable

    #--------------------------------------------------------------------------
    # * Pushes other in self
    #--------------------------------------------------------------------------
    def <<(oth)
      oth.parent = self
      self.children ||= []
      self.children << oth
      compute
      oth
    end

    #--------------------------------------------------------------------------
    # * Pushes self in other
    #--------------------------------------------------------------------------
    def >>(oth)
      self.parent = oth
      oth.children ||= []
      oth.children << self
      compute
      oth
    end
    #--------------------------------------------------------------------------
    # * Parents
    #--------------------------------------------------------------------------
    def parents
      return [] unless parent
      parents = [parent]
      parents << parents[-1].parent while parents[-1].parent
      parents
    end
    #--------------------------------------------------------------------------
    # * Computing
    #--------------------------------------------------------------------------
    def compute
      compute_self
      recompute_children
    end
    #--------------------------------------------------------------------------
    # * Computes self
    #--------------------------------------------------------------------------
    def compute_self
    end
    #--------------------------------------------------------------------------
    # * Children recomputing
    #--------------------------------------------------------------------------
    def recompute_children
      children.each{|c| c.compute} if self.children
    end

  end

  #==============================================================================
  # ** RectComputing
  #------------------------------------------------------------------------------
  #  Baby's shape
  #==============================================================================

  module RectComputing

    #--------------------------------------------------------------------------
    # * Computing rules
    #--------------------------------------------------------------------------
    module Rules

      class << self
        attr_accessor :values
        Rules.values = Hash.new
        delegate_accessor :values, :[]
      end

      self[:none] = proc do |r|
        r.true_x      = r.abs_x  = r.x
        r.true_y      = r.abs_y  = r.y
        r.true_width  = r.width
        r.true_height = r.height
      end

      self[:relative] = proc do |r|
        pa = r.parent.inner
        r.true_x      = r.abs_x  = r.x + pa.abs_x
        r.true_y      = r.abs_y  = r.y + pa.abs_y
        r.true_width  = r.width
        r.true_height = r.height
      end

      self[:enclosed] = proc do |r|
        pa = r.parent.inner
        ax = r.abs_x  = r.x + pa.abs_x
        ay = r.abs_y  = r.y + pa.abs_y
        mx = ax + r.width
        my = ay + r.height
        lx = pa.true_x + pa.true_width
        ly = pa.true_y + pa.true_height
        r.true_x      = ax.bound(pa.true_x, lx)
        r.true_y      = ay.bound(pa.true_y, ly)
        r.true_width  = mx.bound(pa.true_x, lx) - r.true_x
        r.true_height = my.bound(pa.true_y, ly) - r.true_y
      end

    end
    #--------------------------------------------------------------------------
    # * Legacy of Rect
    #--------------------------------------------------------------------------
    attr_accessor :legacy_rule
    #--------------------------------------------------------------------------
    # * Computes real Rect from legacy rules
    #--------------------------------------------------------------------------
    def compute_self
      if self.parent
        @legacy_rule ||= :enclosed
        Rules[@legacy_rule][self]
      else
        Rules[:none][self]
      end
    end

  end

end

#==============================================================================
# ** Numeric
#------------------------------------------------------------------------------
# Managing digits separately
#==============================================================================

class Numeric
   def percent
     @percent = true
   end
   def percent?
     @percent
   end
end

#==============================================================================
# ** Rect
#------------------------------------------------------------------------------
#  The rectangle class.
#==============================================================================

class Rect

  #--------------------------------------------------------------------------
  # * Import Imbrication API
  #--------------------------------------------------------------------------
  include Generative::Stackable
  include Generative::RectComputing
  #--------------------------------------------------------------------------
  # * Public instances variables
  #--------------------------------------------------------------------------
  attr_accessor :children, :parent, :abs_x, :abs_y
  #--------------------------------------------------------------------------
  # * Alias
  #--------------------------------------------------------------------------
  alias_method :true_x,  :x
  alias_method :true_y,  :y
  alias_method :true_x=, :x=
  alias_method :true_y=, :y=
  alias_method :true_width,   :width
  alias_method :true_height,  :height
  alias_method :true_width=,  :width=
  alias_method :true_height=, :height=
  #--------------------------------------------------------------------------
  # * Auto-computing
  #--------------------------------------------------------------------------
  [
    :x,
    :y,
    :width,
    :height
  ].each{|m| attr_accessor_callback :compute, m}
  #--------------------------------------------------------------------------
  # * Gets properties
  #--------------------------------------------------------------------------
  def abs_x;  @abs_x  ||= true_x; end
  def abs_y;  @abs_y  ||= true_y; end
  def x;      @x      ||= true_x; end
  def y;      @y      ||= true_y; end
  def width;  @width  ||= true_width;  end
  def height; @height ||= true_height; end
  #--------------------------------------------------------------------------
  # * Sets all parameters at once
  #--------------------------------------------------------------------------
  def set(*args)
    return if parameters == args || clone == args[0]
    if (a = args[0]).is_a? Rect
      @x, @y, @width, @height = a.x, a.y, a.width, a.height
    else
      @x, @y, @width, @height = *args
    end
    compute
  end
  #--------------------------------------------------------------------------
  # * Sets all components to 0.
  #--------------------------------------------------------------------------
  def empty
    @x = @y = @width = @height = self.true_x = self.true_y =
    self.true_width = self.true_height = 0
  end
  #--------------------------------------------------------------------------
  # * Gets real Rect computed from legacy rules
  #--------------------------------------------------------------------------
  def computed
    Rect.new(true_x, true_y, true_width, true_height)
  end
  #--------------------------------------------------------------------------
  # * Clone
  #--------------------------------------------------------------------------
  def clone
    Rect.new(*parameters)
  end
  alias :dup :clone
  #--------------------------------------------------------------------------
  # * Returns parameters into Array format
  #--------------------------------------------------------------------------
  def parameters
    [self.x, self.y, self.width, self.height]
  end
  #--------------------------------------------------------------------------
  # * Sets parameters without auto-computing
  #--------------------------------------------------------------------------
  def set_parameters(x, y, w, h)
    @x = x
    @y = y
    @width = w
    @height = h
  end
  #--------------------------------------------------------------------------
  # * check if point 's include in the rect
  #--------------------------------------------------------------------------
  def in?(*p)
    point = p.to_point
    point.in?(self.computed)
  end
  #--------------------------------------------------------------------------
  # * Inception
  #--------------------------------------------------------------------------
  def inner
    self
  end

end

#==============================================================================
# ** Viewport
#------------------------------------------------------------------------------
#  Used when displaying sprites on one portion of the true
#==============================================================================

class Viewport

  #--------------------------------------------------------------------------
  # * Import Imbrication API
  #--------------------------------------------------------------------------
  include Generative::Stackable
  #--------------------------------------------------------------------------
  # * Alias
  #--------------------------------------------------------------------------
  alias_method :true_z,  :z
  alias_method :true_z=, :z=
  alias_method :true_ox,  :ox
  alias_method :true_ox=, :ox=
  alias_method :true_oy,  :oy
  alias_method :true_oy=, :oy=
  alias_method :inner, :rect
  alias_method :sdk_dispose, :dispose
  #--------------------------------------------------------------------------
  # * Delegation
  #--------------------------------------------------------------------------
  [
    :children,
    :parent
  ].each{|m| delegate_accessor :rect, m}
  #--------------------------------------------------------------------------
  # * Auto-computing when changing parameters
  #--------------------------------------------------------------------------
  [
    :ox,
    :oy,
    :x,
    :y,
    :width,
    :height
  ].each{|m| attr_accessor_callback :compute, m}
  #--------------------------------------------------------------------------
  # * Gets properties
  #--------------------------------------------------------------------------
  def ox;         @ox     ||= true_ox; end
  def oy;         @oy     ||= true_oy; end
  def x;          @x      ||= rect.x;  end
  def y;          @y      ||= rect.y;  end
  def z;          @z      ||= true_z;  end
  def width;      @width  ||= rect.width;  end
  def height;     @height ||= rect.height; end
  #--------------------------------------------------------------------------
  # * The viewport's z-coordinate.
  #--------------------------------------------------------------------------
  def z=(v)
    if @z != v
      @z = v
      compute_z
    end
  end
  #--------------------------------------------------------------------------
  # * Computes real Rect from legacy rules
  #--------------------------------------------------------------------------
  def compute_self
    rect.set(self.x, self.y, self.width, self.height)
    rect.compute_self
    self.true_ox = rect.true_x - rect.abs_x + self.ox
    self.true_oy = rect.true_y - rect.abs_y + self.oy
    compute_z
  end
  #--------------------------------------------------------------------------
  # * Computes real z-coordinate from legacy rule
  #--------------------------------------------------------------------------
  def compute_z
    if self.parent && self.parent.respond_to?(:z)
      self.true_z = self.z + self.parent.true_z + 1
    else
      self.true_z = self.z
    end
    if self.children
      self.children.each{|c| c.respond_to?(:compute_z) && c.compute_z}
    end
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    @disposed = true
    self.parent.children.delete(self) if self.parent
    self.children.each{|c| c.dispose} if self.children
    sdk_dispose
  end
  attr_reader :disposed
  alias_method :disposed?, :disposed
end

#==============================================================================
# ** GUI
#------------------------------------------------------------------------------
#  Graphical User interface
#==============================================================================

module Gui

  #==============================================================================
  # ** Style
  #------------------------------------------------------------------------------
  #  Telling what the things looks like
  #==============================================================================

  class Style

    def initialize
      @values = Hash.new
      set background_color: Color.new(*[255]*3),
          border_color:     Color.new(*[0]*3),
          border:           1,
          border_width:     1,
          border_radius:    0,
          font:             'Standard',
          height:           :auto,
          max_height:       nil,
          min_height:       0,
          width:            :auto,
          max_width:        nil,
          min_width:        0,
          padding:          8,
          margin:           0
    end

    def [](k)
      @values[k.to_sym]
    end

    def []=(k,v)
      @values[k.to_sym] = v
    end

    def set(args)
      args.each do |k,v|
        if [:margin, :padding, :border].include?(k)
          set_param(k, *v)
        else
          self[k] = v
        end
      end
    end

    def set_param(m, *args)
      m = m.to_s
      case args.length
      when 1
        self["#{m}_bottom"] = self["#{m}_top"]   =
        self["#{m}_left"]   = self["#{m}_right"] = args[0]
      when 2
        self["#{m}_bottom"] = self["#{m}_top"]   = args[0]
        self["#{m}_left"]   = self["#{m}_right"] = args[1]
      when 3
        self["#{m}_bottom"] = args[0]
        self["#{m}_top"]    = args[2]
        self["#{m}_left"]   = self["#{m}_right"] = args[1]
      else
        self["#{m}_bottom"], self["#{m}_top"],
        self["#{m}_left"],   self["#{m}_right"]  = *args
      end
    end

    def contract_with(m, r)
      m = m.to_s
      x = r.x + self["#{m}_left"]
      y = r.y + self["#{m}_top" ]
      w = r.width  - self["#{m}_left"] - self["#{m}_right" ]
      h = r.height - self["#{m}_top" ] - self["#{m}_bottom"]
      r.set x, y, w, h
    end

    def css_match(obj)
      Gui::CSS.apply_to(obj)
    end
  end

  #==============================================================================
  # ** CSS
  #------------------------------------------------------------------------------
  #  Telling what the things looks like LEVEL 2
  #==============================================================================

  module CSS
    class << self
      attr_accessor :entries
      delegate_accessor :entries, :[]
      CSS.entries = Hash.new
      def apply_to(obj)
        entries.each do |selector, style|
          obj.style.set(style) if selector[obj]
        end
      end
    end

    def set(*selectors, style)
      selectors.each do |s|
        s = s+'._' unless s.include?('.')
        s = '_ '+s unless s.include?(' ')
        s = s.split(/\ |\./)
        sl = proc do |obj|
          c1 = s[0] == "_" || obj.parents.any?{|pa| pa.class.to_s == s[0]}
          c2 = s[1] == ""  || obj.class.to_s == s[1]
          c3 = s[2] == "_" || obj.respond_to?(:name) && obj.name.to_s == s[2]
          c1 && c2 && c3
        end
        CSS[sl] = style
      end
    end

  end

  #==============================================================================
  # ** GUI::Tools
  #------------------------------------------------------------------------------
  #  Graphical User interface helpers
  #==============================================================================

  module Tools

    class << self
      def random_color
        Color.new(rand(255), rand(255), rand(255))
      end
      def password_char
        '•'
      end
    end

    module Activable
      def actived?
        @active
      end
      def activate
        @active = true
      end
      def deactivate
        @active = false
      end
      def trigger_activation
        @active = !@active
      end
      def activation_callback
        @activation_callback
      end
      def set_activation_callback(&block)
        @activation_callback = lambda{|s| false}
        @activation_callback = block if block_given?
      end
      def check_callback
        if @activation_callback
          if @activation_callback.call(self)
            @active = true
          end
        end
      end
    end

  end

  #==============================================================================
  # ** GUI::Components
  #------------------------------------------------------------------------------
  #  Graphical User interface components
  #==============================================================================

  module Components

    #==============================================================================
    # ** Text_Field
    #------------------------------------------------------------------------------
    #  IZI Things
    #==============================================================================

    class Text_Field
      #--------------------------------------------------------------------------
      # * IZI Public instance variables
      #--------------------------------------------------------------------------
      [
        :in?,
        :hover?,
        :click?,
        :press?,
        :trigger?,
        :repeat?,
        :release?,
        :mouse_x,
        :mouse_y,
        :>>,
        :<<,
        :dispose
      ].each{|m| delegate :@viewport, m}
      delegate_accessor :@text, :value
      delegate_accessor :@text, :virtual_position
      delegate_accessor :@text, :selection_start
      delegate :@text, :formatted_value
      delegate :@text, :has_transformation?
      delegate :@text, :delete
      [:x, :y].each{|m| delegate_accessor :@viewport, m}

      include Tools::Activable
      #--------------------------------------------------------------------------
      # * IZI Object initialize
      #--------------------------------------------------------------------------
      def initialize(textrecorder,x,y,w,font="Standard",active=false,&block)
        @active = active
        @text = textrecorder
        @x,@y,@w = x,y,w
        @font = get_profile(font).to_font
        @text.start_capture
        @cursor_timer = 0
        create_sprite
        create_viewport
        create_selection_rect
        create_cursor
        set_activation_callback(&block)
        update_bitmap
        update_cursor_pos
      end
      #--------------------------------------------------------------------------
      # * Refresh
      #--------------------------------------------------------------------------
      def refresh
        update_bitmap
        update_cursor_pos
        update_selection_rect
        update_viewport
      end
      #--------------------------------------------------------------------------
      # * IZI Update
      #--------------------------------------------------------------------------
      def update
        unless actived?
          @cursor.opacity = 0
          check_callback
        else
          locate if press?(:mouse_left) || Mouse.dragging? && in?(Mouse.drag.start)
          @text.update unless Devices::Keys::Enter.press? || Devices::Keys::Tab.press?
          update_bitmap if @text.has_transformation?
          if @text.cursor_has_moved?
            update_cursor_pos
            update_selection_rect
            update_viewport
          end
          update_cursor_blink
        end
      end
      #--------------------------------------------------------------------------
      # * IZI Sprite creation
      #--------------------------------------------------------------------------
      def create_sprite
        @sprite = Sprite.new
        @sprite.bitmap = Bitmap.new(1,1)
        @sprite.bitmap.font = @font
        @split_format = 640 / @sprite.bitmap.text_size("W").width
      end
      #--------------------------------------------------------------------------
      # * IZI Viewport creation
      #--------------------------------------------------------------------------
      def create_viewport
        @h = @sprite.bitmap.text_size("W").height
        @viewport = Viewport.new(@x,@y,@w,@h)
        @sprite.viewport = @viewport
      end
      #--------------------------------------------------------------------------
      # * IZI Cursor creation
      #--------------------------------------------------------------------------
      def create_cursor
        @cursor = Sprite.new(@viewport)
        @cursor.bitmap = Bitmap.new(1,@h)
        @cursor.bitmap.fill_rect(0,0,1,@h,Color.new(0,0,0))
        @cursor.ox = 1
      end
      def create_selection_rect
        @selection_rect = Sprite.new(@viewport)
        @selection_rect.bitmap = Bitmap.new(1,1)
        @selection_rect.bitmap.fill_rect(0,0,1,1,Color.new(51,153,255))
        @selection_rect.zoom_x = 0
        @selection_rect.zoom_y = @h
        @selection_rect.z = -1
      end
      #--------------------------------------------------------------------------
      # * IZI Bitmap update
      #--------------------------------------------------------------------------
      def update_bitmap
        text = value
        text = " " if text.empty?
        rect = @sprite.bitmap.text_size(text)
        @sprite.bitmap.dispose
        @sprite.bitmap = Bitmap.new(rect.width, rect.height)
        @sprite.bitmap.font = @font
        last_x = 0
        text.split_each(@split_format).each do |a_text|
          rect = @sprite.bitmap.text_size(a_text)
          rect.x = last_x
          @sprite.bitmap.draw_text(rect, a_text)
          last_x += rect.width
        end
      end
      #--------------------------------------------------------------------------
      # * IZI Cursor blink
      #--------------------------------------------------------------------------
      def update_cursor_blink
        @cursor_timer = (@cursor_timer + 1/20.0)%2
        @cursor.opacity = @cursor_timer < 1 ? 255 : 0
      end
      #--------------------------------------------------------------------------
      # * IZI Cursor position update
      #--------------------------------------------------------------------------
      def update_cursor_pos
        @cursor_timer = 0
        pos = @text.virtual_position
        if pos == 0
          @cursor.x = 1
        else
          @cursor.x = @sprite.bitmap.text_size(value[0...pos]).width
        end
      end
      #--------------------------------------------------------------------------
      # * IZI Selection Rect update
      #--------------------------------------------------------------------------
      def update_selection_rect
        pos = @text.selection_start
        if pos == 0
          @selection_rect.x = 1
        else
          @selection_rect.x = @sprite.bitmap.text_size(value[0...pos]).width
        end
        delta = @cursor.x - @selection_rect.x
        @selection_rect.zoom_x = delta.abs
        @selection_rect.x += delta if delta < 0
      end
      #--------------------------------------------------------------------------
      # * IZI Viewport update
      #--------------------------------------------------------------------------
      def update_viewport
        a = @cursor.x - @w
        b = @sprite.bitmap.width - @w
        @viewport.ox = @viewport.ox.bound(a, b).bound(0, @cursor.x-1)
      end
      #--------------------------------------------------------------------------
      # * IZI Cursor location on click
      #--------------------------------------------------------------------------
      def locate
        x = mouse_x + @viewport.ox
        approx = x * value.length / @sprite.bitmap.width
        match = approach(approx, x)
        @text.cursor_jump(match)
        @viewport.ox -= 10 if mouse_x < 0
        @viewport.ox += 10 if (@w - mouse_x) < 0
      end
      #--------------------------------------------------------------------------
      # * IZI Approach
      #--------------------------------------------------------------------------
      def approach(a, x, memoa=a, memob=0)
        bound = a.bound(0,value.length)
        return bound if bound != a
        b = @sprite.bitmap.text_size(value[0...a]).width
        return a if (b-x) == 0 || (b-x)==(x-memob)
        return memoa if (b-x).abs > (memob-x).abs
        approach(a + (0 <=> (b-x)), x, a, b)
      end

    end

    #==============================================================================
    # ** TextRecorder
    #------------------------------------------------------------------------------
    #  Record text state
    #==============================================================================

    class Abstract_Recorder
      #--------------------------------------------------------------------------
      # * Public instance variables
      #--------------------------------------------------------------------------
      attr_accessor :exit_keys
      attr_accessor :stopped
      attr_accessor :transformed
      attr_accessor :cursor_moved
      attr_accessor :virtual_position
      attr_accessor :selection_start
      alias_method :stopped?, :stopped
      def value=(v); @value = v; end
      def value; @value; end
      def formatted_value; @value; end

      #--------------------------------------------------------------------------
      # * Has a transformation
      #--------------------------------------------------------------------------
      def has_transformation?
        result = @transformed
        @transformed = false
        result
      end
      #--------------------------------------------------------------------------
      # * Cursor has moved
      #--------------------------------------------------------------------------
      def cursor_has_moved?
        result = @cursor_moved
        @cursor_moved = false
        result
      end
      #--------------------------------------------------------------------------
      # * Cursor jump
      #--------------------------------------------------------------------------
      def cursor_jump(v)
        @virtual_position = v
        bound_cursor
      end
      #--------------------------------------------------------------------------
      # * Start capture
      #--------------------------------------------------------------------------
      def start_capture
        @stopped = false
        update
      end
      #--------------------------------------------------------------------------
      # * Sop capture
      #--------------------------------------------------------------------------
      def stop_capture
        @stopped = true
      end
      #--------------------------------------------------------------------------
      # * Bound cursor position
      #--------------------------------------------------------------------------
      def bound_cursor
        @virtual_position = @virtual_position.bound(0, @value.length)
        @cursor_moved = true
        c = [nil, ''].include?(Keyboard.current_char)
        @selection_start = @virtual_position unless (Keyboard.shift && c || Mouse.dragging?)
      end
      #--------------------------------------------------------------------------
      # * go left
      #--------------------------------------------------------------------------
      def go_left
        @virtual_position -= 1
        bound_cursor
      end
      #--------------------------------------------------------------------------
      # * go Right
      #--------------------------------------------------------------------------
      def go_right
        @virtual_position += 1
        bound_cursor
      end
      #--------------------------------------------------------------------------
      # * Update key capture
      #--------------------------------------------------------------------------
      def update
        return if stopped?
        return stop_capture if @exit_keys.any?{|key| Keyboard.repeat?(key)}
        update_virtual_cursor
        update_value_modification
        update_value
        update_clipboard
      end
      #--------------------------------------------------------------------------
      # * Running
      #--------------------------------------------------------------------------
      def recording?
        !stopped?
      end
      #--------------------------------------------------------------------------
      # * Update text content
      #--------------------------------------------------------------------------
      def update_value
        return if @limit && @value.length >= @limit
        c = Keyboard.current_char
        unless [nil, ''].include?(c)
          delete(0)
          @value = @value.insert_at(@virtual_position, c)
          @transformed = true
          go_right
        end
      end
      #--------------------------------------------------------------------------
      # * Delete between
      #--------------------------------------------------------------------------
      def delete(dir=-1)
        range = [@virtual_position, @selection_start].sort
        if range[0] == range[1]
          return if @virtual_position == 0
          range[0] -= 1 if dir == -1
          range[1] += 1 if dir == 1
        end
        @value = @value.delete_between(*range)
        @virtual_position = @selection_start = range[0]
        @cursor_moved = @transformed = true
      end
      #--------------------------------------------------------------------------
      # * Update text content (bcps and del)
      #--------------------------------------------------------------------------
      def update_value_modification
        if Keyboard.krepeat?(0x08)
          delete
        end
        if Keyboard.krepeat?(0x2E)
          delete(1)
        end
      end
      #--------------------------------------------------------------------------
      # * Update cursor position
      #--------------------------------------------------------------------------
      def update_virtual_cursor
        go_left if Keyboard.krepeat?(0x25)
        go_right if Keyboard.krepeat?(0x27)
      end
      #--------------------------------------------------------------------------
      # * Update clipboard
      #--------------------------------------------------------------------------
      def update_clipboard
        if Keyboard.ctrl?(:c)
          c = value[Range.new(*[@selection_start, @virtual_position].sort,true)]
          Clipboard.push_text(c) unless c.empty?
        end
        if Keyboard.ctrl?(:x)
          c = value[Range.new(*[@selection_start, @virtual_position].sort,true)]
          Clipboard.push_text(c) unless c.empty?
          delete(0)
        end
        if Keyboard.ctrl?(:v)
          delete(0)
          c = Clipboard.get_text
          @value = @value.insert_at(@virtual_position, c)
          @virtual_position += c.length
          @transformed = true
          bound_cursor
        end
      end
    end

    #==============================================================================
    # ** TextRecorder
    #------------------------------------------------------------------------------
    #  Record text state
    #==============================================================================

    class Text_Recorder < Abstract_Recorder
      #--------------------------------------------------------------------------
      # * Object initialize
      #--------------------------------------------------------------------------
      def initialize(init = "", limit = nil , exit_keys = [])
        @transformed = true
        @stopped = true
        @exit_keys = exit_keys
        @limit = limit
        @value = init
        @value = init[0...@limit] if @limit
        @virtual_position = @selection_start = init.length
      end
    end

    #==============================================================================
    # ** Int_Recorder
    #------------------------------------------------------------------------------
    #  Record int state
    #==============================================================================

    class Int_Recorder < Abstract_Recorder
      #--------------------------------------------------------------------------
      # * Object initialize
      #--------------------------------------------------------------------------
      def initialize(init = 0, limit = nil , exit_keys = [])
        @transformed = true
        @stopped = true
        @exit_keys = exit_keys
        @limit = limit
        @value = init
        @value = init.bound(@limit.min, @limit.max) if @limit
        @value = @value.to_s
        @virtual_position = @selection_start = @value.length
      end
      #--------------------------------------------------------------------------
      # * Value accessor
      #--------------------------------------------------------------------------
      def formatted_value;
        self.value=@value
        @value.to_i
      end
      def value; @value; end
      def value=(v)
        return @value = v if v == '+' || v == '-'
        @value = v.to_i
        @value = @value.bound(@limit.min, @limit.max) if @limit
        @value = @value.to_s
        @virtual_position = @selection_start = @value.length
      end
      #--------------------------------------------------------------------------
      # * Update text content
      #--------------------------------------------------------------------------
      def update_value
        c = Keyboard.current_char
        unless [nil, ''].include?(c)
          delete(0)
          return unless (["+","-"] + ("0".."9").to_a).include?(c)
          return if @value != "" && ["+","-"].include?(c)
          self.value = @value.insert_at(@virtual_position, c)
          @transformed = true
          go_right
        end
      end
    end

    #==============================================================================
    # ** Int_Recorder
    #------------------------------------------------------------------------------
    #  Record int state
    #==============================================================================

    class Float_Recorder < Abstract_Recorder
      #--------------------------------------------------------------------------
      # * Object initialize
      #--------------------------------------------------------------------------
      def initialize(init = 0.0, limit = nil , exit_keys = [])
        @transformed = true
        @stopped = true
        @exit_keys = exit_keys
        @limit = limit
        @value = init
        @value = [[@limit.min,init].max, @limit.max].min  if @limit
        @value = @value.to_s
        @virtual_position = @selection_start = @value.length
      end
      #--------------------------------------------------------------------------
      # * Value accessor
      #--------------------------------------------------------------------------
      def formatted_value;
        self.value=@value
        @value.to_f
      end
      def value; @value; end
      def value=(v)
        return @value = v if v == '+' || v == '-' || v == '.'
        @value = v.to_s
        if @limit
          result = @value.to_f
          unless @limit.member?(result)
            @value = [[@limit.min,result].max, @limit.max].min.to_s
          end
        end
        @virtual_position = @selection_start = @value.to_s.length
      end
      #--------------------------------------------------------------------------
      # * Update text content
      #--------------------------------------------------------------------------
      def update_value
        c = Keyboard.current_char
        unless [nil, ''].include?(c)
          delete(0)
          return unless (["+","-",'.'] + ("0".."9").to_a).include?(c)
          return if @value != "" && ["+","-"].include?(c)
          return if c == "." && @value.count(".") == 1
          self.value = @value.insert_at(@virtual_position, c)
          @transformed = true
          go_right
        end
      end
    end

  end

  #==============================================================================
  # ** Gui::Box
  #------------------------------------------------------------------------------
  #  Simple box
  #==============================================================================

  class Box
    #--------------------------------------------------------------------------
    # * Import Stackable API
    #--------------------------------------------------------------------------
    include Generative::Stackable

    attr_accessor :inner, :style, :viewport, :name
    [
      :in?,
      :hover?,
      :click?,
      :press?,
      :trigger?,
      :repeat?,
      :release?,
      :mouse_x,
      :mouse_y,
      :x,
      :y,
      :width,
      :height,
      :true_z
    ].each{|m| delegate :viewport, m}
    [
      :children,
      :parent,
      :z
    ].each{|m| delegate_accessor :viewport, m}
    [
      :x,
      :y,
      :width,
      :height
    ].each{|m| attr_accessor_callback :compute, m}

    def initialize(args=nil)
      @name = args[:name] if args && args[:name]
      @viewport = Viewport.new(50, 50, 200, 300)
      if args && args[:parent]
        pa = args[:parent]
        self.parent = pa
        pa.children ||= []
        pa.children << self
      end
      @style = Gui::Style.new
      @style.css_match(self)
      @style.set args[:style] if args && args[:style]
      @background = Sprite.new(@viewport)
      @inner = Rect.new
      @inner >> @viewport
      compute_self
    end

    def update_background
      @background.bitmap = Bitmap.new(self.width, self.height)
      r = Rect.new(0, 0, self.width, self.height)
      @style.contract_with(:margin, r)
      @background.bitmap.fill_rect(r, @style[:border_color])
      @style.contract_with(:border, r)
      @background.bitmap.fill_rect(r, @style[:background_color])
      @style.contract_with(:padding, r)
      @inner.set(r)
    end

    def compute_self
      viewport.x = @x
      viewport.y = @y
      viewport.width = @width
      viewport.height = @height
      viewport.compute_self
      update_background
    end
  end

end

#==============================================================================
# ** Module
#------------------------------------------------------------------------------
#  Link CSS
#==============================================================================

class Module
  include Gui::CSS
  extend Gui::CSS
end

#==============================================================================
# ** CSS
#------------------------------------------------------------------------------
#  Telling what the things looks like
#==============================================================================

module CSS

  set 'Gui::Box',
    padding: 5,
    background_color: get_color('gray'),
    border_color: get_color('blue')

  set 'SuperBilou',
    padding: 10,
    background_color: Gui::Tools.random_color,
    border_color: get_color('red'),
    border_top: 30

  set 'SuperBilou Gui::Box',
    border: 10

  set 'Gui::Box.bernard', 'SuperBilou.lol',
    background_color: get_color('green'),
    border: [2,4,6,8],
    border_left: 20

end
