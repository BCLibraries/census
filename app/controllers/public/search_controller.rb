class Public::SearchController < ApplicationController
  layout "public"

  # GET /public/search
  # GET /public/search.json ???
  #

  def search
    # set the number of results per page for this specific search controller.
    # this overrides the paginates_per variable in the Text model
    @pagination_page_size = 10

    if params[:type] == "adv"
      @search_type = "adv"
    else
      @search_type = "kw"
    end

    if params[:keyword].present? ||
        params[:title].present? ||
        params[:journal].present? ||
        params[:location].present? ||
        params[:people].present? ||
        params[:genre].present?

      query_string_array = []

      if params[:keyword].present?
        query_string_array << {
            query_string: {
                fields: %w{
                  title
                  original
                  original_greek_title
                  date
                  genre
                  material_type
                  text_type
                  journal.title
                  publisher
                  publication_places.place.name
                  topic_author.full_name
                  topic_author.alternate_name
                  text_citations.name
                  components.title
                  components.component_citations.name
                },
                type: "best_fields",
                query: params[:keyword],
            }
        }
      end

      if params[:title].present?
        query_string_array << {
            query_string: {
                fields: ['title'],
                query: params[:title]
            }
        }
      end

      if params[:journal].present?
        query_string_array << {
            query_string: {
                fields: ['journal.title'],
                query: params[:journal]
            }
        }
      end

      if params[:location].present?
        query_string_array << {
            query_string: {
                fields: ['publication_places.place.name'],
                query: params[:location]
            }
        }
      end

      if params[:genre].present?
        @genre = params[:genre]
        query_string_array << {
            query_string: {
                fields: ['genre'],
                query: params[:genre]
            }
        }
      end

      if params[:people].present?
        query_string_array << {
            query_string: {
                fields: %w{
                  text_citations.name
                  components.component_citations.name
                  topic_author.full_name
                },
                query: params[:people]
            }
        }
      end

      # create elasticsearch search query
      all_search = {
          query: {
              bool: {
                  must: query_string_array
              }
          },
          aggs: {
              genre: {
                  terms: {
                      field: "genre.keyword"
                  }
              },
              "material_type": {
                  terms: {
                      field: "material_type.keyword"
                  }
              },
              "text_type": {
                  terms: {
                      field: "text_type.keyword"
                  }
              },
              "topic_author": {
                  terms: {
                      field: "topic_author.full_name.keyword"
                  }
              },
              "publication_places": {
                  terms: {
                      field: "publication_places.place.name.keyword"
                  }
              },
              "other_text_languages": {
                  terms: {
                      field: "other_text_languages.language.name.keyword"
                  }
              }
          }
      }

      @texts = Text.search(all_search).page(params[:page]).per(@pagination_page_size)
    else
      @new_search = true
      @texts = []
    end
  end

  private
  def search_params
    params.permit(:keyword, :title, :journal, :location, :people, :type, :genre)
  end
end
