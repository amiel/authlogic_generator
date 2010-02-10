class Hash
  def deep_merge(other_hash) 
    self.inject({}) do |sum, pair| 
      sum[pair[0]] = if (pair[1].is_a? Hash)
        pair[1].merge(other_hash[pair[0]])
      else
        (other_hash[pair[0]] || pair[1])
      end
      sum 
    end
  end
end
