Spree.Views.EditSubscriptionPayment = Backbone.View.extend({
  initialize: function() {
    this.onSelectMethod()
  },

  events: {
    'change [name="subscription[payment_method_id]"]': 'onSelectMethod',
  },

  onSelectMethod: function(e) {
    this.selectedId = parseInt(this.$('select[name="subscription[payment_method_id]"]').val())
    this.render()
  },

  render: function() {
    let selectedId = this.selectedId

    this.$('select[name="subscription[payment_source_id]"] option').each(function () {
      if (!$(this).data('js-payment-method-id') || parseInt($(this).data('js-payment-method-id')) === selectedId) {
        $(this).prop('disabled', false)
      } else {
        $(this).prop('disabled', true)
      }
    })
  },
});

Spree.ready(function() {
  $(".js-edit-subscription-payment").each(function() {
    new Spree.Views.EditSubscriptionPayment({ el: this })
  });
});
