# -*- encoding: utf-8 -*-

module BaseHelpers

  def remote_ip
    @remote_ip ||= @env['REMOTE_ADDR']
  end

end