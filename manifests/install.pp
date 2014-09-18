# Class: logstash::install
#
# This class installs logstash
#
# == Variables
#
# Refer to logstash class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It's automatically included by logstash
#
class logstash::install inherits logstash {

  case $logstash::install {

    package: {
      package { 'logstash':
        ensure => $logstash::manage_package,
        name   => $logstash::package,
      }
    }

    source: {

      $created_file = $logstash::bool_tarball_install ? {
        false => url_parse($logstash::real_install_source,'filename'),
        true  => "logstash-${logstash::version}",
      }
      $file_logstash_link_path = $logstash::bool_tarball_install ? {
        false => "${logstash::logstash_dir}/logstash.jar",
        true  => "${logstash::logstash_dir}/logstash",
      }

      if $logstash::bool_create_user == true {
        require logstash::user

      }
      include logstash::skel

      puppi::netinstall { 'netinstall_logstash':
        url                => $logstash::real_install_source,
        destination_dir    => $logstash::logstash_dir,
        extract_command    => $logstash::real_extract_command,
        preextract_command => $logstash::install_precommand,
        extracted_dir      => $created_file,
        owner              => $logstash::process_user,
        group              => $logstash::process_user,
        before             => File ['logstash_link'],
      }

      file { 'logstash_link':
        ensure  => "${logstash::logstash_dir}/${created_file}" ,
        path    => $file_logstash_link_path,
        require => Puppi::Netinstall ['netinstall_logstash'],
      }

    }

    puppi: {

      if $logstash::bool_create_user == true {
        require logstash::user
      }
      include logstash::skel

      puppi::project::war { 'logstash':
        source                   => $logstash::real_install_source,
        deploy_root              => $logstash::logstash_dir,
        predeploy_customcommand  => $logstash::install_precommand,
        postdeploy_customcommand => $logstash::install_postcommand,
        report_email             => 'root',
        user                     => 'root',
        auto_deploy              => true,
        check_deploy             => false,
        run_checks               => false,
        enable                   => true,
        before                   => File ['logstash_link'],
      }

      file { 'logstash_link':
        ensure  => "${logstash::logstash_dir}/${created_file}" ,
        path    => "${logstash::logstash_dir}/logstash.jar" ,
        require => Puppi::Project::War ['logstash'],
      }

    }

    default: { }

  }

}
