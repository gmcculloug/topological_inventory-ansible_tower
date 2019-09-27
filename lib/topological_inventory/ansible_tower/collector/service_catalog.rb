module TopologicalInventory::AnsibleTower
  class Collector
    module ServiceCatalog
      def get_service_inventories(connection)
        fnc = lambda do |&block|
          enumerator = connection.api.inventories.all(:page_size => limits[:service_inventories])
          enumerator.each do |inventory|
            block.call(inventory)
          end
        end
        TopologicalInventory::AnsibleTower::Iterator.new(fnc, "Couldn't fetch 'service_inventories' of service catalog.")
      end

      def get_service_offerings(connection)
        fnc = lambda do |&block|
          {:job_template          => connection.api.job_templates.all(:page_size => limits[:service_offerings]),
           :workflow_job_template => connection.api.workflow_job_templates.all(:page_size => limits[:service_offerings])}.each_pair do |type, enumerator|
            enumerator.each do |template|
              block.call(
                :template      => template,
                :template_type => type,
                :survey_spec   => get_service_plan(template)
              )
            end
          end
        end
        TopologicalInventory::AnsibleTower::Iterator.new(fnc, "Couldn't fetch 'service_offerings' of service catalog.")
      end

      def get_service_instances(connection)
        fnc = lambda do |&block|
          {:job          => connection.api.jobs.all(:page_size => limits[:service_instances]),
           :workflow_job => connection.api.workflow_jobs.all(:page_size => limits[:service_instances])}.each_pair do |type, enumerator|
            enumerator.each do |job|
              block.call(
                :job      => job,
                :job_type => type
              )
            end
          end
        end
        TopologicalInventory::AnsibleTower::Iterator.new(fnc, "Couldn't fetch 'service_instances' of service catalog")
      end

      # TODO: It seems that each request are sent twice in ansible_tower_client
      # But don't know why yet
      def get_service_plan(template)
        template.survey_spec_hash if template.survey_enabled
      end
    end
  end
end
