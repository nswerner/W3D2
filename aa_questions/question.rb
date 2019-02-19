require_relative 'forum.rb'
require_relative 'question_follow.rb'
require_relative 'question_like.rb'

class Question
    attr_accessor :title, :body, :user_id
    attr_reader :id

    def self.all
        data = ForumDBConnection.instance.execute('SELECT * FROM questions;')
        data.map { |datum| Question.new(datum)}
    end 

    def self.find_by_id(id)
        ForumDBConnection.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                questions
            WHERE
                questions.id = ?
        SQL
    end 

    def self.find_by_author_id(user_id)
        ForumDBConnection.instance.execute(<<-SQL, user_id)
            SELECT
                *
            FROM
                questions
            WHERE
                questions.user_id = ?
        SQL
    end

    def self.most_followed(n)
        QuestionFollow.most_followed_questions(n)
    end

    def self.most_liked(n)
        QuestionLike.most_liked_questions(n)
    end

    def initialize(options)
        @id = options['id']
        @title = options['title']
        @body = options['body']
        @user_id = options['user_id']
    end

    def create
        raise "That question already exists" if id

        ForumDBConnection.instance.execute(<<-SQL, title, body, user_id)
            INSERT INTO 
                questions (title, body, user_id) 
            VALUES 
                (?, ?, ?)
        SQL

        @id = ForumDBConnection.instance.last_insert_row_id
    end

    def update 
        raise "Question does not exist" unless id 

        ForumDBConnection.instance.execute(<<-SQL, title, body, user_id, id)
            UPDATE
                questions 
            SET 
                title = ?, body = ?, user_id = ?
            WHERE 
                id = ? 
        SQL
    end 

    def author
        User.find_by_id(self.user_id)
    end
    
    def replies
        Reply.find_by_question_id(self.id)
    end

    def followers
        QuestionFollow.followers_for_question_id(self.id)
    end 

    def likers 
        QuestionLike.likers_for_question_id(self.id)
    end 

    def num_likes 
        QuestionLike.num_likes_for_question_id(self.id)
    end 
end