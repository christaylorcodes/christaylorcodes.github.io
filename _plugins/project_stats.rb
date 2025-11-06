# frozen_string_literal: true

# Project Stats Plugin
#
# This plugin enriches project collection items with statistics from _data/project-stats.yml
# It adds 'stars' and 'gallery_downloads' properties to each project, enabling sorting
# and filtering without needing complex Liquid templates.
#
# Usage:
#   Projects will automatically have .stars and .gallery_downloads properties available
#   {% assign sorted_projects = site.projects | sort: 'stars' | reverse %}

Jekyll::Hooks.register :site, :post_read do |site|
  # Get the project stats data
  stats_data = site.data['project-stats']

  next unless stats_data

  # Enrich each project with its stats
  site.collections['projects'].docs.each do |project|
    # Extract project ID from the file basename (without extension)
    project_id = File.basename(project.basename, '.*')

    # Look up stats for this project
    project_stats = stats_data[project_id]

    if project_stats
      # Add stars and gallery_downloads to the project data
      project.data['stars'] = project_stats['stars'] || 0
      project.data['gallery_downloads'] = project_stats['gallery_downloads'] || 0
    else
      # Default values if no stats found
      project.data['stars'] = 0
      project.data['gallery_downloads'] = 0
    end
  end
end
