#determine required command line parameters
flags = []

#TODO: Grab file list using Grunt function
modules = ['handler', 'listener', 'usb', 'devices']

module.exports = (grunt) ->
  options = {}

  #read the package file for this Grunt compiler
  pkg = grunt.file.readJSON('package.json')

  #loop over all flags and ensure they are set
  for flag in flags
    pkg[flag] = grunt.option(flag)
    unless pkg[flag]?
      throw "No #{flag} parameter supplied, use --#{flag}"

  #read all devices - #jsonify is custom function (bottom of file)
  devices = grunt.file.readJSON('devices.json')

  #log some debugging information
  grunt.log.oklns "Building #{pkg.title}. Version #{pkg.version}"
  grunt.log.subhead "Using module: #{module}" for module in modules
  
  grunt.initConfig {
    #push package settings to configuration
    pkg: pkg

    #run coffeelint on all files to ensure coding conformity
    coffeelint: {
      build: ['src/**/*.coffee']
    },

    #concatenate external third party libraries into a singular file
    concat: {
      options: {
        stripBanners: true,
        banner: "/*! Application Dependencies /*\n"
      },
      build: {
        src: ['bower_components/*/jquery.js', 'bower_components/*/require.js'],
        dest: 'build/libs.js'
      }
    },

    #compile coffeescript files into javascript files inside the build directory
    coffee: {
      build: {
        expand: true,
        flatten: false,
        cwd: 'src',
        src: ['**/*.coffee'],
        dest: 'build/',
        ext: '.js'
      }
    },

    #run the requirejs optimizer to resolve module dependencies into one file
    requirejs: {
      build: {
        options: {
          out: "build/main.js",
          baseUrl: "build",
          paths: (->
            obj = {}
            obj[module] = "modules/#{module}" for module in modules
            return obj
          )(),
          include: modules
        }
      }
    },

    #uglify all remaining javascript inside the build directory
    uglify: {
      options: {
        banner: "/* #{pkg.title} #{pkg.version} - Compiled: <%= grunt.template.today(\"yyyy-mm-dd\") %> */\n",
        report: 'min'
      },
      build: {
        expand: true,
        flatten: false,
        cwd: 'build',
        src: ['**/*.js'],
        dest: 'build/',
        ext: '.js'
      }
    },

    #replace all occurences of command line flags inside files
    replace: {
      build: {
        options: {
          variables: (->
            #format devices object into Chrome Manifest standard
            pkg.devices = JSON.stringify((->
              obj = {}
              #loop through ports
              for key, port of devices
                arr = []
                #loop through each type for each port
                for type of port
                  #get the supported device in each type
                  for device in port[type]
                    #push vendorID and productID to array
                    arr.push device.device
                obj[key] = arr
              return obj
            )())
            return pkg
          )()
        }
        files: [
          { src: "manifest.json", dest: "build/manifest.json" },
        ]
      }
    },

    #copy files into the build
    copy: {
      build: {
        files: [
          { src: 'devices.json', dest: 'build/devices.json' }
        ]
      }
    }
  }

  #load npm tasks
  grunt.loadNpmTasks "grunt-#{task}" for task in [
    'contrib-coffee', 
    'contrib-copy', 
    'contrib-concat', 
    'contrib-concat', 
    'contrib-uglify', 
    'coffeelint', 
    'contrib-requirejs',
    'replace'
  ]

  #Register tasks and associated npm tasks
  grunt.registerTask 'build', ['coffeelint', 'concat', 'coffee', 'requirejs', 'uglify', 'replace', 'copy']

