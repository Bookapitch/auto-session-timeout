module AutoSessionTimeoutHelper
  def auto_session_timeout_js(options={})
    frequency = options[:frequency] || 60
    attributes = options[:attributes] || {}
    path_to_timeout = send([options[:namespace], "timeout_path"].compact.join("_"))
    path_to_active = send([options[:namespace], "active_path"].compact.join("_"))
    code = <<JS
function PeriodicalQuery() {
  var request = new XMLHttpRequest();
  request.onload = function (event) {
    var status = event.target.status;
    var response = event.target.response;
    if (status === 200 && (response === false || response === 'false' || response === null)) {
      window.location.href = '#{path_to_timeout}';
    }
  };
  request.open('GET', '#{path_to_active}', true);
  request.responseType = 'json';
  request.send();
  setTimeout(PeriodicalQuery, (#{frequency} * 1000));
}
setTimeout(PeriodicalQuery, (#{frequency} * 1000));
JS
    javascript_tag(code, attributes)
  end
end

ActionView::Base.send :include, AutoSessionTimeoutHelper
