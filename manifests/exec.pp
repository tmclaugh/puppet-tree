# $Id: exec.pp 993 2012-06-21 01:34:45Z tom $

$exec_path = $::operatingsystem ? {
	centos => ["/bin", "/sbin", "/usr/bin", "/usr/sbin", "/usr/local/bin", "/usr/local/sbin", "/usr/kerberos/sbin", "/usr/kerberos/bin", "/usr/X11R6/bin", "/usr/X11R6/sbin"],
	default => ["/bin", "/sbin", "/usr/bin", "/usr/sbin"],
}

Exec { path => $exec_path, logoutput => true}

exec { "newaliases":
	refreshonly => true
}
