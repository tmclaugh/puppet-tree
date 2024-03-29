# Common functions for doing file edits.
#
# http://projects.puppetlabs.com/projects/puppet/wiki/Simple_Text_Patterns
# http://labs.alunys.com/viewvc/projects/puppet/trunk/manifests/

define line($file, $line, $ensure = 'present') {
	case $ensure {
		default : { err ( "unknown ensure value ${ensure}" ) }
		present: {
			exec { "echo '${line}' >> '${file}'":
			unless => "grep -qFx '${line}' '${file}'"
			}
		}

		absent: {
			exec { "perl -ni -e 'print unless /^\\Q${line}\\E\$/' '${file}'":
				onlyif => "grep -qFx '${line}' '${file}'"
			}
		}

		uncomment: {
			exec { "sed -i -e'/^#\\(\\s\\)\\?${line}/s/^#\\(\\s\\)\\?\+//' '${file}'":
				# XXX: This has been changed from the
				# orginal version from checking if a
				# commented line exists to checking if
				# an uncommented line exists. In
				# addition this will only modify lines
				# that start with '#' and optionally a
				# spaces before $line.  This fixes
				# cases where $line appears in a comemnt.

				# XXX: Because this ignores a leading
				# white space it can be an issue if the
				# value appears at the beginning of a
				# comement line.  This should ideally be
				# handled.  See sshd_config for examples
				# of that.

				unless => "grep '${line}' '${file}' | grep '^${line}'"
			}
		}

		comment: {
			exec { "sed -i -e'/${line}/s/^\(.\+\)$/#\1/' '${file}'":
				onlyif => "test `grep '${line}' '${file}' | grep -v '^#' | wc -l` -ne 0"
			}
		}
	}
}

define append_if_no_match($file, $line, $match, $refreshonly = 'false') {
	exec { "echo -e '$line' >> '$file'":
		unless => "grep -Exqe '$match' '$file'",
		refreshonly => $refreshonly,
	}
}

define append_if_no_such_line($file, $line, $refreshonly = 'false') {
	exec { "echo -e '$line' >> '$file'":
		unless => "grep -Exqe '$line' '$file'",
		refreshonly => $refreshonly,
	}
}

define prepend_if_no_such_line($file, $line, $refreshonly = 'false') {
	exec { "perl -p0i -e 's/^/$line\n/;' '$file'":
		unless => "grep -Fxqe '$line' '$file'",
		refreshonly => $refreshonly,
	}
}

define delete_lines($file, $pattern) {
	exec { "sed -i -r -e '/$pattern/d' $file":
		onlyif => "grep -E '$pattern' '$file'",
	}
}

define delete_line_if_other($file, $pattern, $delpattern) {
	exec { "sed -i -r -e '/$delpattern/d' $file":
		onlyif => "grep -E '$pattern' '$file'",
	}
}

# slashes must be escaped.
#
define replace($file, $pattern, $replacement) {
	exec { "perl -pi -e 's/$pattern/$replacement/' '$file'":
		onlyif => "perl -ne 'BEGIN { \$ret = 1; } \$ret = 0 if /$pattern/ && ! /$replacement/ ; END { exit \$ret; }' '$file'",
	}
}

# Pull a file from elsewhere not using puppet://...
 define download_file(
	$site="",
	$cwd="",
	$unless="",
	$timeout = 300) {

	exec { $name:
		command => "wget ${site} -O ${name}",
		cwd => $cwd,
		creates => "${cwd}/${name}",
		timeout => $timeout,
		unless => $unless
	}
}
