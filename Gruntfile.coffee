module.exports = (grunt) ->

  #TODO: Grab file list using Grunt function
  modules = ['handler', 'listener', 'usb']

  grunt.log.oklns 'Building Ferret'
  grunt.log.subhead "Found module: #{module}" for module in modules
  
  grunt.initConfig {
    pkg: grunt.file.readJSON('package.json'),

    coffeelint: {
      build: ['src/**/*.coffee']
    },

    copy: {
      build: {
        files: [
          { src: "manifest.json", dest: "build/manifest.json" }
        ]
      }
    },

    concat: {
      options: {
        stripBanners: true,
        banner: "/*! Application Dependencies /*\n"
      },
      build: {
        src: ['bower_components/*/index.js', 'bower_components/*/require.js'],
        dest: 'build/libs.js'
      }
    },

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

    uglify: {
      options: {
        banner: '/* <%= pkg.name %> <%= pkg.version %> - Compiled: <%= grunt.template.today("yyyy-mm-dd") %> */\n',
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
    'contrib-requirejs'
  ]

  #Register tasks and associated npm tasks
  grunt.registerTask 'build', ['coffeelint', 'copy', 'concat', 'coffee', 'requirejs', 'uglify']

