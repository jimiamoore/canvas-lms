define [
  'jquery'
  'underscore'
  'jst/content_migrations/MigrationConverter'
  'compiled/views/ValidatedFormView'
  'vendor/jquery.ba-tinypubsub'
  'jquery.disableWhileLoading'
], ($, _, template, ValidatedFormView) -> 

  # This is an abstract class that is inherited 
  # from by other MigrationConverter views
  class MigrationConverterView extends ValidatedFormView
    @optionProperty 'selectOptions'

    template: template
    
    els: 
      '#converter'                : '$converter'
      '#chooseMigrationConverter' : '$chooseMigrationConverter'
      '.form-container'           : '$formActions'

    events: _.extend({}, @::events,
      'change #chooseMigrationConverter' : 'selectConverter'
      'click .cancelBtn'                 : 'resetForm'
    )

    toJSON: (json) -> 
      json = super
      json.selectOptions = @selectOptions || ENV.SELECT_OPTIONS
      json

    # Render a backbone view (converter view) into
    # the converter div. Removes anything in the 
    # converter div if there were any previous 
    # items set. 

    renderConverter: (converter) -> 
      if converter
        converter.setElement @$converter
        converter.render()
      else
        @resetForm() 

    # This is the actual action for making the view swaps when selecting
    # a different converter view. Ensures that when you select a new view
    # you are resetting the models data to it's dynamic defaults and setting
    # it's migration_type to the view being shown. 
    #
    # @api private

    selectConverter: (event) -> 
      @$formActions.show()
      @model.resetModel()
      @model.set 'migration_type', @$chooseMigrationConverter.val()
      $.publish 'contentImportChange', {value: @$chooseMigrationConverter.val(), migrationConverter: this}

    # Submit the form and call .save on the model. Handles validations. This override will
    # wait until the save is complete then publish the models attributes on an event that 
    # is listened to in the content_migration bundle file. It also resets the form and 
    # model. The reason for dfd?.done instead of dfd.done is because super has the possiblity
    # of returning null. In that case, we don't want to do anything cause there were errors.
    #
    # @expects event
    # @api ValidatedFormView override

    submit: (event) -> 
      dfd = super
      dfd?.done => 
        $.publish 'migrationCreated', @model.attributes
        @model.resetModel()
        @resetForm()

    # Reseting the form will hide the submit buttons, 
    # clear the form html and change the dropdown menu to be nothing. Model date gets reset 
    # when switching dropdowns so should be fine. 
    #
    # @api private

    resetForm: -> 
      @$formActions.hide()
      @$converter.empty()
      @$chooseMigrationConverter.val('none')

