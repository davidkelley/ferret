module.exports = (grunt) ->
  
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
      options: {
        banner: '/*! <%= pkg.name %> <%= pkg.version %> */\n'
      },
      build: {
        expand: true,
        flatten: false,
        cwd: 'src',
        src: ['**/*.coffee'],
        dest: 'build/',
        ext: '.js'
      }
    }
  }

  #load npm tasks
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-coffeelint'
  #grunt.loadNpmTasks 'grunt-contrib-requirejs'

  #Register tasks and associated npm tasks
  grunt.registerTask 'build', ['coffeelint', 'copy', 'concat', 'coffee']