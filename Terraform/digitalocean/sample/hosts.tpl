all:
  children:
    c2proxy:
      hosts:
%{ for content_key, content_value in content }
%{~ if length(regexall("c2proxy", content_key)) > 0 ~}
        ${content_key}:
%{ endif ~}
%{~ endfor ~}
    gophish:
      hosts:
%{ for content_key, content_value in content }
%{~ if length(regexall("gophish", content_key)) > 0 ~}
        ${content_key}:
%{ endif ~}
%{~ endfor ~}
    mailu:
      hosts:
%{ for content_key, content_value in content }
%{~ if length(regexall("mailu", content_key)) > 0 ~}
        ${content_key}:
%{ endif ~}
%{~ endfor ~}
    nextcloud:
      hosts:
%{ for content_key, content_value in content }
%{~ if length(regexall("nextcloud", content_key)) > 0 ~}
        ${content_key}:
%{ endif ~}
%{~ endfor ~}
    evilginx:
      hosts:
%{ for content_key, content_value in content }
%{~ if length(regexall("evilginx", content_key)) > 0 ~}
        ${content_key}:
%{ endif ~}
%{~ endfor ~}
    clonesite:
      hosts:
%{ for content_key, content_value in content }
%{~ if length(regexall("clonesite", content_key)) > 0 ~}
        ${content_key}:
%{ endif ~}
%{~ endfor ~}
    c2server:
      hosts:
%{ for content_key, content_value in content }
%{~ if length(regexall("c2server", content_key)) > 0 ~}
        ${content_key}:
%{ endif ~}
%{~ endfor ~}
    recon:
      hosts:
%{ for content_key, content_value in content }
%{~ if length(regexall("recon", content_key)) > 0 ~}
        ${content_key}:
%{ endif ~}
%{~ endfor ~}
    axiom:
      hosts:
%{ for content_key, content_value in content }
%{~ if length(regexall("axiom", content_key)) > 0 ~}
        ${content_key}:
%{ endif ~}
%{~ endfor ~}
