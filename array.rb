module UsuiHon
  refine Array do
    def +(num)
      self.map{|y| y.map{|x| x + num } }
    end

    def -(num)
      self.map{|y| y.map{|x| x - num } }
    end

    def *(num)
      self.map{|y| y.map{|x| x * num } }
    end

    def /(num)
      self.map{|y| y.map{|x| x / num } }
    end
  end
end
