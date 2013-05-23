ActiveAdmin.register Coupon do
	actions :all, :except => [:destroy]

  index do
    selectable_column
    column :id
    column :code
    column :discount
    column :discount_type
    column :active
    column :featured
    column :start_date
    column :expiration_date
    column "Times Used", :usage_count
    column :max_usage
    column :description
    default_actions
  end

  form do |f|
    f.inputs "Coupon Details" do
      f.input :promotion
      f.input :featured
      f.input :code, hint: "Leave blank if you want the system to generate the code automatically"
      f.input :max_usage, hint: "The maximum number of times the same coupon can be used"
      f.input :discount, hint: "For percentage discounts (20%) enter '20'; for fixed discounts enter the amount in dollars"
      f.input :discount_type, :as => :select, :collection => ["fixed", "percentage"]
      f.input :max_discount, hint: "If entered, this is the maximum amount that will be deducted from the price"
      f.input :start_date
      f.input :expiration_date
      f.input :description, hint: "Will be shown in places like the featured box in the home page"
      f.input :allowed_products, :label => "Allowed Products",
                :as => :check_boxes,
                :multiple => true,
                :collection => APPRAISAL_PLANS,
                :member_label => Proc.new { |t|  APPRAISAL_PLANS_NAMES[t] },
                :hint => "If no produccts are selected, then the coupon will be valid for any type of appraisal"

      f.buttons
    end
  end
end
